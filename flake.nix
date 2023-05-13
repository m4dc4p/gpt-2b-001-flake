{
  description = "A very basic flake";

  inputs.nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.NeMo = {
    url = "github:NVIDIA/Nemo?rev=e6ee3312fb3f35b9d95b54b64c2abed4574708b9";
    flake = false;
  };
  inputs.megatron-lm = {
    url = "github:NVIDIA/Megatron-LM?rev=9f8bdeb4814ed61fbc9c7d5b39c7710e77b99754";
    flake = false;
  };

  nixConfig = {
    bash-prompt-prefix = "develop >";
  };

  outputs = { self, flake-utils, nixpkgs-unstable, NeMo, megatron-lm }: 
    let
      systems = [ "x86_64-linux" ];
    in
      flake-utils.lib.eachSystem systems (system: 
        let 
          pkgs-unstable = (import nixpkgs-unstable { 
            inherit system; 
            config.allowUnfree = true; 
            config.cudaCapabilities = [ "8.6" ];
            config.cudaForwardCompat = false;
          });
          inherit (pkgs-unstable) 
            cudaPackages_11_8
            python3
            python3Packages 
            stdenv;

          # Use the latest CUDA tools supported by pytorch (11.8).
          cudaPackages = cudaPackages_11_8;
          torchWithCuda = python3Packages.pytorchWithCuda.override { 
            inherit cudaPackages; 
            magma = pkgs-unstable.magma.override { inherit cudaPackages; };
          };

          huggingface-hub = python3Packages.buildPythonPackage { 
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/58/34/c57b951aecd0248845932c1cfc15721237c50e463f26b0536673bcb76f4f/huggingface_hub-0.14.1-py3-none-any.whl";
              sha256 = "sha256:09sgrhyb8pi0042v1dg1a4q7ij2mq9brfz6k79wz63w01lbikilz";
            };

            doCheck = false;
            doInstallCheck = false;

            nativeBuildInputs = with python3Packages; [ 
              filelock
              fsspec
              requests
              tqdm
              pyyaml
              typing-extensions
              packaging
            ];

            pname = "huggingface-hub";
            version = "0.14.1";
            format = "wheel";
          };

          charset-normalizer = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/db/51/a507c856293ab05cdc1db77ff4bc1268ddd39f29e7dc4919aa497f0adbec/charset_normalizer-2.1.1-py3-none-any.whl";
              sha256 = "sha256:17z2zvkvalb66i5hasshq0grsma8afs6hb1mi7yrl9qi35fsgsc3";
            };

            doCheck = false;
            doInstallCheck = false;

            nativeBuildInputs = with python3Packages; [ 
            ];

            pname = "charset-normalizer";
            version = "2.1.1";
            format = "wheel";
          };
          nemo-toolkit = python3Packages.buildPythonPackage {
            src = NeMo;

            pname = "nemo_toolkit";
            version = "1.18.0rc0";
            format = "setuptools";
            doInstallCheck = false;
            doCheck = false;

            pythonRelaxDeps = [ "setuptools" ];

            nativeBuildInputs = with python3Packages; [
              pythonRelaxDepsHook
              tqdm
              numba
              tensorboard
              huggingface-hub
              text-unidecode
              onnx
              ruamel-yaml
              scikit-learn
              torchWithCuda
              wget
              wrapt
              python-dateutil
              fsspec
              filelock
              packaging
            ];
          };
          lightning-utilities = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/5d/ec/a20c5d5f26894913da028110310ba55ee254e1b7ff0ff78441e4eeb7291f/lightning_utilities-0.8.0-py3-none-any.whl";
              sha256 = "sha256:0viavrcmrimrj4ldpka886q3x43hndg8h22dyp70rxf8a5xi1ai2";
            };

            nativeBuildInputs = with python3Packages; [ 
              typing-extensions
              packaging
            ];

            pname = "lightning-utilities";
            version = "0.8.0";
            format = "wheel";
          };
          mdurl = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/b3/38/89ba8ad64ae25be8de66a6d463314cf1eb366222074cfda9ee839c56a4b4/mdurl-0.1.2-py3-none-any.whl";
              sha256 = "sha256:1y5qjqhmq2nm7xj6w5rrp503r7jhj7zr2qcnr6gs858nwm0ql044";
            };

            nativeBuildInputs = with python3Packages; [ 
              typing-extensions
              packaging
            ];

            pname = "mdurl";
            version = "0.1.2";
            format = "wheel";
          };
          markdown-it-py = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/bf/25/2d88e8feee8e055d015343f9b86e370a1ccbec546f2865c98397aaef24af/markdown_it_py-2.2.0-py3-none-any.whl";
              sha256 = "sha256:0c6cs28g2s5m500rf15g3dirn4j6q4nn36bvqjndjw81hz8zhdas";
            };

            nativeBuildInputs = with python3Packages; [ 
              mdurl
            ];

            pname = "markdown-it-py";
            version = "2.2.0";
            format = "wheel";
          };
          mdit-py-plugins = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/33/eb/c358112e8265f827cf8228eda36cf2a720ad933f5ca66f47f808edf4bb34/mdit_py_plugins-0.3.3-py3-none-any.whl";
              sha256 = "sha256:1f847s8ijgwn1mv45m3rg0p17azbsdqs92ydrlxc97pivqlqml1n";
            };

            nativeBuildInputs = with python3Packages; [ 
              mdurl
              markdown-it-py
            ];

            pname = "mdit-py-plugins";
            version = "0.3.3";
            format = "wheel";
          };
          pytorch-lightning-1_9_5 = pkgs-unstable.python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/77/ed/7d91e1958f0d48b439fae0de8ece3de3ce8c3d4e03b04bd3c007ba879a49/pytorch_lightning-1.9.5-py3-none-any.whl";
              sha256 = "sha256:1ianq4vigxynlracyfnd18g6dgf89lvx1lzmxk9ca8w62mc1b0h6";
            };

            catchConflicts = false;
            nativeBuildInputs = with python3Packages; [ 
              aiohttp
              torchmetrics
              torchWithCuda
              lightning-utilities
              tqdm
              fsspec
            ];

            pname = "pytorch-lightning";
            version = "1.9.5";
            format = "wheel";
          };
          youtokentome = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/9a/ae/f8b0d15696766eb35dda6cf84a23d42ae7f3ba37aa30e5e2287fd94ac053/youtokentome-1.0.6.tar.gz";
              sha256 = "sha256:13s4dqd5cwg5sxak88vkczbdjj3w74sl7c55liipsk401c8zqwif";
            };

            doCheck = false;
            doInstallCheck = false;

            nativeBuildInputs = with python3Packages; [ 
              setuptools
              click
              pytest
              tabulate
              cython_3
            ];

            pname = "youtokentome";
            version = "1.0.6";
          };
          webdataset = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/17/ca/a6c031bc1590789a3da14bd6a9cccc46c932401765d6d8f37e75c8214b44/webdataset-0.2.48-py3-none-any.whl";
              sha256 = "sha256:0cf7pkacwixxby0xj6wfazxxjrsd8cbb7jq3pxffzz8afaanil76";
            };

            doCheck = false;
            doInstallCheck = false;

            nativeBuildInputs = with python3Packages; [ 
              braceexpand
              numpy
              pyyaml
            ];

            pname = "webdataset";
            version = "0.2.48";
            format = "wheel";
          };
          sacrebleu = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/30/09/986d4df9ab18e7b12c145851491c89df4ef90f0d380f62bf4490aeb642a4/sacrebleu-2.3.1-py3-none-any.whl";
              sha256 = "sha256:1rq2igdx4nk4hk3ghaf42wafmw6gr3kgxlb6j98fs14yraw2f8im";
            };

            doCheck = false;
            doInstallCheck = false;

            nativeBuildInputs = with python3Packages; [ 
              portalocker
              regex
              tabulate
              numpy
              colorama
              lxml
            ];

            pname = "sacrebleu";
            version = "2.3.1";
            format = "wheel";
          };
          opencc = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/15/d3/2e5c61f218e51a0f767b05e257f52e53b9ecafe8ef84541e8765a42c64f0/OpenCC-1.1.6-cp310-cp310-manylinux1_x86_64.whl";
              sha256 = "sha256:15gbi1gk5i0sll45i2ca2qq0vxnq2gn7szlxjq1iyiqwmbw3kyk8";
            };

            doCheck = false;
            doInstallCheck = false;

            nativeBuildInputs = with python3Packages; [ 
            ];

            pname = "opencc";
            version = "1.1.6";
            format = "wheel";
          };
          pangu = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/48/77/b52fac2ca4e4596f22dd6200b99ad515fb64b1ae7d3a12325b45b11e2a67/pangu-4.0.6.1-py3-none-any.whl";
              sha256 = "sha256:01h2s1x8n07vglg9wn4fixsgpx4cpgy7x152c7nag3dl6knxq8sh";
            };

            doCheck = false;
            doInstallCheck = false;

            nativeBuildInputs = with python3Packages; [ 
            ];

            pname = "pangu";
            version = "4.0.6.1";
            format = "wheel";
          };
          ipadic = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/e7/4e/c459f94d62a0bef89f866857bc51b9105aff236b83928618315b41a26b7b/ipadic-1.0.0.tar.gz";
              sha256 = "sha256:01qwlzlm0ipnfrj3l3b4gcsb2rc6k7c2iv8qmz51l4x6xhqkv4pm";
            };

            doCheck = false;
            doInstallCheck = false;

            nativeBuildInputs = with python3Packages; [ 
            ];

            pname = "ipadic";
            version = "1.0.0";
          };
          gradio_client = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/a5/4f/bc020875f9d4f0299dc7b123d94595dfc2449f3a24fb56fadac0d9022ea9/gradio_client-0.1.4-py3-none-any.whl";
              sha256 = "sha256:0h4d2f9fmccs0g84c6259mksq0x2qmm378z3n6gg65yqzshgacj2";
            };

            doCheck = false;
            doInstallCheck = false;

            nativeBuildInputs = with python3Packages; [ 
              huggingface-hub
              fsspec
              packaging
              httpx
              websockets
              pyyaml
              filelock
            ];

            pname = "gradio_client";
            version = "0.1.4";
            format = "wheel";
          };
          rouge_score = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/e2/c5/9136736c37022a6ad27fea38f3111eb8f02fe75d067f9a985cc358653102/rouge_score-0.1.2.tar.gz";
              sha256 = "sha256:010gzwbsszlz3f55b3l4dxk46rm4cdfr3vrm06zrm376hckdmm67";
            };

            doCheck = false;
            doInstallCheck = false;

            nativeBuildInputs = with python3Packages; [ 
              absl-py
              nltk
              numpy
              six
            ];

            pname = "rouge_score";
            version = "0.1.2";
          };
          ffmpy = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/bf/e2/947df4b3d666bfdd2b0c6355d215c45d2d40f929451cb29a8a2995b29788/ffmpy-0.3.0.tar.gz";
              sha256 = "sha256:1p4sdxxjvysk5x8y0iyv6d2pk8imh2svkzy91ajv89gf3rc92xbm";
            };

            doCheck = false;
            doInstallCheck = false;

            nativeBuildInputs = with python3Packages; [ 
            ];

            pname = "ffmpy";
            version = "0.3.0";
          };
          aiohttp = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/c2/fd/1ff4da09ca29d8933fda3f3514980357e25419ce5e0f689041edb8f17dab/aiohttp-3.8.4.tar.gz";
              sha256 = "sha256:0p5bj6g7ca19gvwk8fz00k579ma9w9kd27ssh2zl3r61ca8ilbmz";
            };

            doCheck = false;
            doInstallCheck = false;

            nativeBuildInputs = with python3Packages; [ 
              charset-normalizer
              multidict
              frozenlist
              async-timeout
              aiosignal
              attrs
              yarl
            ];

            pname = "aiohttp";
            version = "3.8.4";
          };
          gradio = python3Packages.buildPythonPackage {
            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/bd/76/e10954a28d01e0231437148396b5dcf10f2af4850bf84baa52fefb473ed5/gradio-3.28.3-py3-none-any.whl";
              sha256 = "sha256:06kf13qfywxva6flia677vrifda2x9wcl5smnfazmi9jajnl2yrj";
            };

            doCheck = false;
            doInstallCheck = false;
            catchConflicts = false;

            nativeBuildInputs = with python3Packages; [ 
              aiofiles
              aiohttp
              altair
              fastapi
              fsspec
              filelock
              ffmpy
              gradio_client
              httpx
              huggingface-hub
              jinja2
              linkify-it-py
              markdown-it-py
              pygments
              mdit-py-plugins
              markupsafe
              matplotlib
              mdurl
              numpy
              orjson
              pandas
              pillow
              pydantic
              python-multipart
              pydub
              pyyaml
              requests
              semantic-version
              typing-extensions
              uvicorn
              websockets
            ];

            pname = "gradio";
            version = "3.28.3";
            format = "wheel";
          };
          protobuf3_20_1 = pkgs-unstable.protobuf3_20.overrideAttrs (_: { 
            version = "3.20.1"; 
          });
          pyProtobuf3_20_1 = (python3Packages.protobuf3.override { 
            protobuf = protobuf3_20_1; 
          }).overrideAttrs (_: {
            doCheck = false;
            doInstallCheck = false;            
          });
          apex = pkgs-unstable.python3Packages.buildPythonPackage rec {
            name = "apex";
            version = "0.0.1";
            src = builtins.fetchGit {
              url = "https://github.com/NVIDIA/apex";
              name = "apex";
              rev = "6bd01c4b99a84648ad5e5238a959735e6936c813";
              shallow = true;
            };
            patches = [ ./apex.patch ];
            doCheck = false;
            doInstallCheck = false;
            # catchConflicts = false;

            nativeBuildInputs = with python3Packages; [ setuptools-scm 
                cxxfilt
                numpy
                pyyaml
                pytest
                packaging
                torchWithCuda
                cudaPackages.cudatoolkit
                pkgs-unstable.which
                pkgs-unstable.ninja
                pybind11
                nemo-toolkit
                pkgs-unstable.makeWrapper
                pkgs-unstable.gcc11
              ];

            setupPyGlobalFlags = [ "--cpp_ext" "--cuda_ext" "--fast_layer_norm" "--distributed_adam" "--deprecated_fused_adam" ];

            preBuild = ''
              LIBCUDA_PATH='' + "\${LIBCUDA_PATH:-/usr/lib/wsl/lib}" + ''

              if [[ ! -f $LIBCUDA_PATH/libcuda.so ]]; then
                echo "libcuda.so not found at using LIBCUDA_PATH (which was: '$LIBCUDA_PATH'). Did you set --option sandbox false?"
                exit 1
              else
                echo "Using libcuda.so at $LIBCUDA_PATH"
              fi

              export LD_LIBRARY_PATH=$LIBCUDA_PATH:$LD_LIBRARY_PATH
              export CPATH=${python3Packages.pybind11}/include:${cudaPackages.cudatoolkit}/include:$CPATH
              export LIBRARY_PATH=${python3Packages.pybind11}/lib:${cudaPackages.cudatoolkit.lib}/lib:$LIBCUDA_PATH:$LIBRARY_PATH
            '';
          };
          transformers = python3Packages.transformers.overrideAttrs (old: {
            propagatedBuildInputs = [ huggingface-hub python3Packages.fsspec ] ++ (builtins.filter (p: (! p ? pname) || p.pname != "huggingface-hub") old.propagatedBuildInputs);
          });
          megatron-gpt-eval-def = rec {
            python = python3.withPackages (ps: with ps; [
              aiofiles
              altair
              apex
              braceexpand
              colorama
              dateutil
              einops
              fastapi
              ffmpy
              flask
              flask-restful
              fsspec
              gradio
              gradio_client
              h5py
              httpx
              hydra-core
              ijson
              ipadic
              jieba
              lightning-utilities
              lxml
              markdown-it-py
              matplotlib
              mdit-py-plugins
              mecab-python3
              mdurl
              nemo-toolkit
              nltk
              omegaconf
              onnx
              opencc
              orjson
              packaging
              pandas
              pangu
              portalocker
              psutil
              pydub
              pytorch-lightning-1_9_5
              rouge_score
              sacrebleu
              sacremoses
              scikit-learn
              semantic-version
              sentencepiece
              tabulate
              torchWithCuda
              torchmetrics
              transformers
              uvicorn
              websockets
              webdataset
              wget
              wrapt
              youtokentome
            ]);
            script = pkgs-unstable.writeTextFile {
                name = "megatron_gpt_eval";
                text = ''
                  #!/bin/sh

                  PATH=${python}/bin:${pkgs-unstable.coreutils}/bin:$PATH
                  export PYTHONPATH=${megatron-lm}:$PYTHONPATH

                  gpt_model_file=$1

                  if [[ -z "$gpt_model_file" ]]; then
                    echo "Please provide a model file to evaluate."
                    exit 1
                  fi
                  
                  gpt_model_file=$(readlink -f $gpt_model_file)


                  LIBCUDA_PATH='' + "\${LIBCUDA_PATH:-/usr/lib/wsl/lib}" + ''

                  if [[ ! -f $LIBCUDA_PATH/libcuda.so ]]; then
                    echo "libcuda.so not found at using LIBCUDA_PATH (which was: '$LIBCUDA_PATH')"
                  fi

                  export LD_LIBRARY_PATH=$LIBCUDA_PATH:$LD_LIBRARY_PATH

                  (cd ${NeMo}/examples/nlp/language_modeling; \
                  ${python}/bin/python megatron_gpt_eval.py "$@")
                '';
              };
            server =  stdenv.mkDerivation rec {
              name = "megatron-gpt-eval";
              version = "0.0.0";
              dontUnpack = true;
              dontBuild = true;
              installPhase = ''
                runHook preInstall

                mkdir -p $out/bin
                cp ${script} $out/bin/${name}
                chmod +x $out/bin/${name}

                runHook postInstall
              '';

            };
          };

          chat-pg = 
            let
              script = pkgs-unstable.writeTextFile {
                name = "chat.py";
                text = ''
import json
import requests

port_num = 5555
headers = {"Content-Type": "application/json"}

def request_data(prompt):
    data = {
        "sentences": [prompt]*1,
        "tokens_to_generate": 500,
        "temperature": 0.5,
        "add_BOS": False,
        "top_k": 0,
        "top_p": 0.9,
        "greedy": False,
        "all_probs": False,
        "repetition_penalty": 1.2,
        "min_tokens_to_generate": 2,
    }
    resp = requests.put('http://localhost:{}/generate'.format(port_num),
                        data=json.dumps(data),
                        headers=headers)
    sentences = resp.json()['sentences']
    return sentences


while True:
    try:
        user_input = input("Enter something: ")
        response = request_data(user_input)
        print("\n".join(response))
    except KeyboardInterrupt:
        print("\nInterrupted by user. Exiting...")
        break
    except Exception as e:
        print(f"An error occurred: {e}")
                '';
              };
              python = python3.withPackages (ps: [ ps.requests ]);
            in stdenv.mkDerivation {
                name = "chat.py";
                version = "0.0.0";
                buildInputs = [ pkgs-unstable.makeWrapper ];
                dontUnpack = true;
                dontBuild = true;
                installPhase = ''
                  runHook preInstall

                  mkdir -p $out/bin
                  cat <<-EOF > $out/bin/$name
                  ${python}/bin/python ${script}
                  EOF
                  chmod +x $out/bin/$name

                  wrapProgram $out/bin/$name

                  runHook postInstall                
                '';
              };

          shell = pkgs-unstable.mkShell {
              packages = [];
              buildInputs = [ megatron-gpt-eval-def.python ];
              shellHook = ''
                
                LIBCUDA_PATH='' + "\${LIBCUDA_PATH:-/usr/lib/wsl/lib}" + ''

                if [[ ! -f $LIBCUDA_PATH/libcuda.so ]]; then
                  echo "libcuda.so not found at using LIBCUDA_PATH (which was: '$LIBCUDA_PATH')"
                fi

                export LD_LIBRARY_PATH=$LIBCUDA_PATH:$LD_LIBRARY_PATH

                export PYTHONPATH=${megatron-lm}:$PYTHONPATH

              '';
            };         
        in 
          { 
            devShell = shell;
            devShells =  {
              default = shell;
            };
            packages = {
              megatron-gpt-eval = megatron-gpt-eval-def.server;
              chat = chat-pg;
            };
            apps = rec {
              default = megatron-gpt-eval;

              megatron-gpt-eval = {
                type = "app";
                program = "${megatron-gpt-eval-def.server}/bin/${megatron-gpt-eval-def.server.name}";
              };

              chat = {
                type = "app";
                program = "${chat-pg}/bin/${chat-pg.name}";
              };

            };
          }
      );
}
