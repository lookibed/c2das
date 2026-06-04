//! Comment location — not supported in daScript output.
use super::*;

impl<'c> Translation<'c> {
    pub fn locate_comments(&mut self) {}

    pub fn get_span(&self, _id: CStmtId) -> Option<()> {
        None
    }
}
