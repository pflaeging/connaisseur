#!/bin/bash
set -uo pipefail

failed=0

for i in {1..50}; do
  shas=("03febde8d2417075eff5f430f95f143c28584964" "40dd739bf6540417e9c545d536b2be28f3c7b19c" "a96d5292de3217f1ab95ccedb4748643a35f5231")
  num_shas=${#shas[@]}
  for index in $(seq 0 $((${num_shas} - 1 )) | sort --random-sort); do
    current_sha=${shas[${index}]}
    echo "Iteration ${i}; testing sha ${current_sha}"
    git checkout ${current_sha}
    make docker
    kind load docker-image securesystemsengineering/connaisseur:v2.1.1
    kind load docker-image securesystemsengineering/connaisseur:helm-hook-v1.0
    bash tests/integration/integration-test.sh >> "correct_test_${current_sha}.log" 2>&1
    if [[ $? -ne 0 ]]; then
      failed=$((${failed} + 1))
      echo "[FAIL] Failed for try $i and sha ${current_sha}"
      make uninstall
      make annihilate
      kubectl delete ns connaisseur
      rm output.log
    fi
    git checkout "helm/"
    make annihilate
    kubectl delete ns connaisseur
  done
done
echo "$failed failed"
