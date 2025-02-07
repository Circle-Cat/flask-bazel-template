load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load("@pypi//:requirements.bzl", "requirement")
load("@rules_oci//oci:defs.bzl", "oci_load", "oci_push")
load("@rules_python//python:defs.bzl", "py_binary", "py_library", "py_test")
load("//:py_layer.bzl", "py_oci_image")

package(default_visibility = ["//flask_bazel_sample:__subpackages__"])

exports_files(
    [
        ".ruff.toml",
    ],
    visibility = ["//tools/lint:lint_access_file_group"],  #lint file group
)

alias(
    name = "format",
    actual = "//tools/format",
)

py_library(
    name = "all_files",
    srcs = glob(["**/*.py"]),
)

py_binary(
    name = "flask_bazel_sample",
    srcs = ["app.py"],
    main = "app.py",
    deps = [
        "@pypi//flask",
    ],
)

py_test(
    name = "app_test",
    srcs = ["app_test.py"],
    deps = [
        ":flask_bazel_sample",
    ],
)

py_oci_image(
    name = "flask_image",
    base = "@python_base",
    binary = ":flask_bazel_sample",
    entrypoint = ["/flask_bazel_sample"],
)

platform(
    name = "aarch64_linux",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:aarch64",
    ],
)

platform(
    name = "x86_64_linux",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
)

platform_transition_filegroup(
    name = "platform_image",
    srcs = [":flask_image"],
    target_platform = select({
        "@platforms//cpu:arm64": ":aarch64_linux",
        "@platforms//cpu:x86_64": ":x86_64_linux",
    }),
)

# (auto) generate REPO,TAG files for dynamic oci_push
genrule(
    name = "dynamic_repository",
    outs = ["final_repository.txt"],
    cmd = """
    REPO=$${REPO:-index.docker.io/alice/repo}  # nonexistent REPO; please pass in real REPO through environment parameters
    echo "$$REPO" > $@
    """,
)

genrule(
    name = "dynamic_tags",
    outs = ["final_tags.txt"],
    cmd = """
    TAG=$${TAG:-latest}  # if TAG not defined, use default value; or pass in TAG through environment parameters
    echo "$$TAG" > $@
    """,
)

# dynamic oci_push
oci_push(
    name = "flask_image_push_dynamic",
    image = ":platform_image",
    remote_tags = ":dynamic_tags",
    repository_file = ":dynamic_repository",
)
