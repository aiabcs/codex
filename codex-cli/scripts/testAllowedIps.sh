#!/bin/bash
next_instance="$HOME/src/codex-tests/test007"
export OPENAI_ALLOWED_DOMAINS="api4c9f86da943f4670bed2f3d40d8847c382yedt9t163bf3zfpiw1h.eastus2.cloudapp.azure.com api.openai.com pypi.org a2043.dscr.akamai.net apif52012fb91654e8c9f8a14aaecaa8c6f44erawvbyh5bf5t2q3xms.northcentralus.cloudapp.azure.com  a918.dscr.akamai.net waws-prod-ch1-ca8d2570.sip.p.azurewebsites.windows.net waws-prod-ch1-fbae39a0.sip.p.azurewebsites.windows.net waws-prod-ch1-fa793126.sip.p.azurewebsites.windows.net"

echo "Testing allowed IPs for domains: $OPENAI_ALLOWED_DOMAINS"

echo "To run a FIREWALL test, you can use the following command:"
# for simple .NET 8 MVC app to manage books in a public library
echo "./scripts/run_in_container.sh --work_dir $next_instance \"echo hello world\""

# then do
echo "cd app$next_instance"
echo "python3 -m venv .venv"
echo "chmod +x .venv/bin/activate"
echo ".venv/bin/activate"
echo ".venv/bin/pip3 install -r requirements.txt"

# for .net small console app with restore and build
echo "To run a .NET test, you can use the following command:"
echo "cd app$next_instance"
echo "dotnet new console -n MyConsoleApp"
echo "cd MyConsoleApp"
echo "dotnet add package Microsoft.Extensions.DependencyInjection"
echo "dotnet restore"
echo "dotnet build"


