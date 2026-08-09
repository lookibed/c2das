//! c2dascript CLI — subcommand dispatcher.
//! Порт c2rust/src/main.rs 1:1.
//! Ищет бинарники `c2dascript-{subcommand}` рядом с собой и маршрутизирует.

use anyhow::anyhow;
use clap::{crate_authors, App, AppSettings, Arg};
use is_executable::IsExecutable;
use std::borrow::Cow;
use std::collections::HashMap;
use std::env;
use std::ffi::OsStr;
use std::path::PathBuf;
use std::process::{self, Command};

/// A `c2dascript` sub-command.
struct SubCommand {
    path: Option<PathBuf>,
    name: Cow<'static, str>,
}

impl SubCommand {
    /// Find `c2dascript-{name}` executables adjacent to the current binary.
    fn find_all() -> anyhow::Result<Vec<Self>> {
        let cur = env::current_exe()?;
        let cur_name = cur
            .file_name()
            .and_then(|n| n.to_str())
            .ok_or_else(|| anyhow!("no file name for c2dascript"))?;
        let dir = cur.parent().ok_or_else(|| anyhow!("no parent dir"))?;

        let mut cmds = Vec::new();
        for entry in dir.read_dir()? {
            let entry = entry?;
            let ft = entry.file_type()?;
            let path = entry.path();
            let name = path
                .file_name()
                .and_then(|n| n.to_str())
                .and_then(|n| n.strip_prefix(cur_name))
                .and_then(|n| n.strip_prefix('-'))
                .map(|n| n.to_owned())
                .map(Cow::from)
                .filter(|_| ft.is_file() || ft.is_symlink())
                .filter(|_| path.is_executable());
            if let Some(name) = name {
                cmds.push(Self {
                    path: Some(path),
                    name,
                });
            }
        }
        Ok(cmds)
    }

    /// Known subcommands (even if binary not found).
    fn known() -> impl Iterator<Item = Self> {
        ["transpile"].into_iter().map(|name| Self {
            path: None,
            name: name.into(),
        })
    }

    fn all() -> anyhow::Result<impl Iterator<Item = Self>> {
        Ok(Self::known().chain(Self::find_all()?))
    }

    fn invoke<I, S>(&self, args: I) -> anyhow::Result<()>
    where
        I: IntoIterator<Item = S>,
        S: AsRef<OsStr>,
    {
        let path = self
            .path
            .as_ref()
            .ok_or_else(|| anyhow!("subcommand not found (not built): {}", self.name))?;
        let status = Command::new(path).args(args).status()?;
        process::exit(status.code().unwrap_or(1));
    }
}

fn main() -> anyhow::Result<()> {
    let sub_commands = SubCommand::all()?.collect::<Vec<_>>();
    let sub_commands: HashMap<&str, &SubCommand> = sub_commands
        .iter()
        .map(|cmd| (cmd.name.as_ref(), cmd))
        .collect();

    let mut args = env::args_os();
    let sub_cmd_name = args.nth(1);
    let sub_cmd = sub_cmd_name
        .as_ref()
        .and_then(|a| a.to_str())
        .and_then(|name| sub_commands.get(name));

    if let Some(cmd) = sub_cmd {
        return cmd.invoke(args);
    }

    // No subcommand matched — show clap help
    let matches = App::new("c2dascript")
        .version(env!("CARGO_PKG_VERSION"))
        .author(crate_authors!(", "))
        .settings(&[AppSettings::SubcommandRequiredElseHelp])
        .subcommands(sub_commands.keys().map(|name| {
            clap::SubCommand::with_name(name).arg(
                Arg::with_name("args")
                    .multiple(true)
                    .allow_hyphen_values(true),
            )
        }))
        .get_matches();
    let name = matches
        .subcommand_name()
        .ok_or_else(|| anyhow!("no subcommand"))?;
    sub_commands[name].invoke(args)
}
