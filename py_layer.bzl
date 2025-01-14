"""
This module defines utility functions and rules for creating Python OCI images and managing Python layers.

Functions:
- py_layers: Splits a Python binary into separate layers (interpreter, packages, app).
- py_oci_image: Creates an OCI-compliant image using Python layers.
"""

load("@aspect_bazel_lib//lib:tar.bzl", "mtree_spec", "tar")
load("@rules_oci//oci:defs.bzl", "oci_image")

PY_INTERPRETER_REGEX = "\\.runfiles/.*python.*-.*"
SITE_PACKAGES_REGEX = "\\.runfiles/.*/site-packages/.*"

def py_layers(name, binary):
    """
    Splits a Python binary into separate layers for OCI image creation.

    Args:
        name (str): The base name for the layers.
        binary (str): The Python binary to be split into layers.

    Returns:
        list: A list of Bazel targets representing the created layers.
    """

    layers = ["interpreter", "packages", "app"]

    mtree_spec(
        name = name + ".mf",
        srcs = [binary],
    )

    native.genrule(
        name = name + ".interpreter_tar_manifest",
        srcs = [name + ".mf"],
        outs = [name + ".interpreter_tar_manifest.spec"],
        cmd = "grep -v '{}' $< | grep '{}' >$@".format(SITE_PACKAGES_REGEX, PY_INTERPRETER_REGEX),
    )

    native.genrule(
        name = name + ".packages_tar_manifest",
        srcs = [name + ".mf"],
        outs = [name + ".packages_tar_manifest.spec"],
        cmd = "grep '{}' $< >$@".format(SITE_PACKAGES_REGEX),
    )

    native.genrule(
        name = name + ".app_tar_manifest",
        srcs = [name + ".mf"],
        outs = [name + ".app_tar_manifest.spec"],
        cmd = "grep -v '{}' $< | grep -v '{}' >$@".format(SITE_PACKAGES_REGEX, PY_INTERPRETER_REGEX),
    )

    result = []
    for layer in layers:
        layer_target = "{}.{}_layer".format(name, layer)
        result.append(layer_target)
        tar(
            name = layer_target,
            srcs = [binary],
            mtree = "{}.{}_tar_manifest".format(name, layer),
        )

    return result

def py_oci_image(name, binary, tars = [], **kwargs):
    """
    Creates an OCI-compliant image using Python layers.

    Args:
        name (str): The name of the OCI image target.
        binary (str): The Python binary to be included in the image.
        tars (list, optional): Additional tar files to include in the image.
        **kwargs: Additional keyword arguments for the underlying oci_image rule.

    Returns:
        None
    """

    oci_image(
        name = name,
        tars = tars + py_layers(name, binary),
        **kwargs
    )
