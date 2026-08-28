//
//  Main.cpp
//
//  Created by Alec Theriault on 10/4/18.
//
#include <fstream>
#include <iterator>
#include <cstdio>
#include <string>
#include <vector>

#include "AstExporter.hpp"

namespace {

void write_trace(const std::string &path, const char *phase) {
    if (path.empty())
        return;
    std::ofstream out(path, std::ios::app);
    out << "phase=" << phase << '\n';
}

bool write_output(const std::string &path, const std::vector<uint8_t> &bytes) {
    const std::string temporary = path + ".tmp";
    {
        std::ofstream out(temporary, std::ios::binary | std::ios::trunc);
        if (!out)
            return false;
        out.write(reinterpret_cast<const char *>(bytes.data()), bytes.size());
        if (!out)
            return false;
    }
    return std::rename(temporary.c_str(), path.c_str()) == 0;
}

} // namespace

int main(int argc, char *argv[]) {
    std::string output_path;
    std::string trace_path;
    bool debug = false;
    std::vector<const char *> exporter_args;
    exporter_args.reserve(argc);
    exporter_args.push_back(argv[0]);

    for (int index = 1; index < argc; ++index) {
        const std::string argument(argv[index]);
        if (argument == "--c2das-debug") {
            debug = true;
            continue;
        }
        if ((argument == "--c2das-output" || argument == "--c2das-trace") && index + 1 < argc) {
            const std::string value(argv[++index]);
            if (argument == "--c2das-output")
                output_path = value;
            else
                trace_path = value;
            continue;
        }
        exporter_args.push_back(argv[index]);
    }

    configure_exporter_debug(debug);
    int result;
    auto outputs = process(exporter_args.size(), exporter_args.data(), &result, trace_path);

    if (result != 0) {
        write_trace(trace_path, "clang-tooling-error");
        return result;
    }

    if (!output_path.empty()) {
        if (outputs.size() != 1) {
            write_trace(trace_path, "cbor-protocol-error");
            return 70;
        }
        if (!write_output(output_path, outputs.begin()->second)) {
            write_trace(trace_path, "cbor-write-error");
            return 74;
        }
        write_trace(trace_path, "cbor-ready");
        return 0;
    }

    for (auto const &kv : outputs) {
        auto const &filename = kv.first;
        auto const &bytes = kv.second;

        std::ofstream out(filename + ".cbor", out.binary | out.trunc);

        out.write(reinterpret_cast<const char *>(bytes.data()), bytes.size());
    }

    write_trace(trace_path, "cbor-ready");
    return 0;
}
