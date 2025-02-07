load("@aspect_rules_lint//format:defs.bzl", "format_multirun")

package(default_visibility = ["format_access_file_group"])

package_group(
    name = "format_access_file_group",
    packages = [
        "//",
    ],
)

format_multirun(
    name = "format",
    python = "@aspect_rules_lint//format:ruff",
    starlark = "@buildifier_prebuilt//:buildifier",
)
