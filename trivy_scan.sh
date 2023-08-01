#!/bin/bash -xe

echo "Sourcing variables to get values of build_info.json" 
source variable.sh

version="$VERSION"
packageDirPath="$PKG_DIR_PATH"
configFile="build_info.json"
imageName=$IMAGE_NAME
buildDocker=true

cd $packageDirPath
echo "Checking for docker_build value in build_info.json"
buildDocker=$(jq .docker_build $configFile)


if [ $buildDocker == true ];then
	wget https://github.com/aquasecurity/trivy/releases/download/v0.40.0/trivy_0.40.0_Linux-PPC64LE.tar.gz
	tar -xf trivy_0.40.0_Linux-PPC64LE.tar.gz
        chmod +x trivy
        sudo mv trivy /usr/bin
	sudo trivy -q image --timeout 10m -f json ${imageName} > vulnerabilities_results.json
	#curl -s -k -u ${env.dockerHubUser}:${env.dockerHubPassword} --upload-file vulnerabilities_results.json ${url_prefix}/Trivy_vulnerabilities_results.json
	sudo trivy -q image --timeout 10m ${imageName} > vulnerabilities_results.txt
	#curl -s -k -u ${env.dockerHubUser}:${env.dockerHubPassword} --upload-file vulnerabilities_results.txt ${url_prefix}/Trivy_vulnerabilities_results.txt
	sudo trivy -q image --timeout 10m -f cyclonedx ${imageName} > sbom_results.cyclonedx
	#curl -s -k -u ${env.dockerHubUser}:${env.dockerHubPassword} --upload-file sbom_results.cyclonedx ${url_prefix}/Trivy_sbom_results.json
	grep -B2 "Total: " vulnerabilities_results.txt > vulnerabilities_summary.txt
	#curl -s -k -u ${env.dockerHubUser}:${env.dockerHubPassword} --upload-file vulnerabilities_summary.txt ${url_prefix}/Trivy_vulnerability_summary.txt


