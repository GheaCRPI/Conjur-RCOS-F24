### Cloning the Conjur Repository
Before cloning the Conjur repository, ensure that in your choice of IDE, the end of line option is set to \n (which is LF) and not \r\n (CRLF). If it is not, this will result in issues while trying to build and run your Conjur environment. Another solution to this issue would be to clone your Conjur repository using the command line, this will maintain the line endings of the repository (LF).

### Running Conjur with WSL
Building Conjur with WSL might result in an error saying that Docker is not installed. If Docker Desktop is installed, consider building the Conjur environment using Git Bash.

Additionally the error `/usr/bin/env: ‘bash\r’: no such file or directory` may be encountered when building using, which is indicative of an error with end of line settings being CRLF instead of LF. To fix this error refer to [Cloning the Conjur Repository](#Cloning-the-Conjur-Repository)

Starting the Conjur environment – running `./start` – in WSL will normally work if building the environment is successful in Git Bash.

### Running Conjur with Git Bash
When starting Conjur with Git Bash, if the error `/usr/bin/env: ‘ruby’: no such file or directory` is encountered, this also indicates a disrepency with the line endings. To solve this, see [Cloning the Conjur Repository](#Cloning-the-Conjur-Repository).

### Conjur Timing Out
While starting a Conjur environment, the error `error: Conjur not ready after 90 seconds` might be encountered. This error can sometimes be cautiously ignored by changing the alloted build time for conjur. This can be done by using `conjurctl wait -r 300 ` to change the wait time to 300 seconds. The number 300 can be substituted for the amount of time you are willing to allow conjur to build for.

### VSCode Debugging
Ensuring that Ruby Version Manager (RVM) is installed will help simplify the debugging process. Running RubyLSP without RVM may lead to may version conflict errors appearing. 


