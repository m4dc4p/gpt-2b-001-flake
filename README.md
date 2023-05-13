
This repo provides a nix flake that can be used to run the NVIDIA GPT-2B-001 model (https://huggingface.co/nvidia/GPT-2B-001) under
WSL (Windows Subsystem for Linux).

The flake currently hard-codes support for the RTX 3090 (Compute Capability 8.1 from https://en.wikipedia.org/wiki/CUDA#GPUs_supported) and will
not work on a vanilla Linux install, as it assumes the CUDA drivers are in the default location for WSL.

# Quick Start

Nix flakes allow you to run an app without the associated repo; however, for simplicity these instructions assume you have cloned the repo.

The flake provides two apps; a server for hosting the model (`megatron-gpt-eval`, and also the default), and a script sending prompts to
the model (`chat`). 

1. Download the GPT-2B-001 model from https://huggingface.co/nvidia/GPT-2B-001/blob/main/GPT-2B-001_bf16_tp1.nemo and save it locally.
2. Run the server using the following:


```bash
$ nix run --impure --option sandbox false .#megatron-gpt-eval -- \
  gpt_model_file=<absolute path to GPT-2B-001_bf16_tp1.nemo> \
  trainer.precision=bf16 \
  server=True \
  tensor_model_parallel_size=1 \
  trainer.devices=1
```

The path to `GPT-2B-001_bf16_tp1.nemo` must be absolute, as the server will change directories before starting.

Note that this step will take quite awhile the first time, as CUDA, pytorch and other dependencies are downloaded and built. You may be able to speed up your build using
the CUDA maintainers cachix (`cachix use cuda-maintainers`); see instructions at https://nixos.wiki/wiki/CUDA#Building_CUDA_packages_with_Nix.

3. Once the server is running, you can send it prompts using the included chat app:

```bash
$ nix run .#chat
Enter something:
```

# Notes

By default, nixpkgs does not build CUDA artifacts, as they have an unfree license. That means pytorch is not built with CUDA suppor either. This flake
builds pytorch CUDA support. However, under WSL, the CUDA libraries are mounted in a special location (`/usr/lib/wsl/lib`), and in all likelihood
actually run Windows code. 

When buildilng a nix package on Linux (and thus WSL), the "sandbox" option defaults to true, which means that the build cannot see the CUDA libraries. That
is why the `--option sandbox  false` argument must be passed to `nix run` command above.

If your CUDA libraries are in some other location, you can set the `LIBCUDA_PATH` environment variable to point to them.

# NeMo Shell

The flake provides a shell (`nix develop .#`) which should be sufficient to run the `megatron_gpt_eval.py` script directly. 
