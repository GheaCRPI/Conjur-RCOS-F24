## Ghea Chaw meeting summaries and progress

### Meeting 1
Discussed possible contribution, installed Docker through Chrome because it didn't work through Edge. We were told to go through the CONTRIBUTING.md document to check if it made sense if an outside person were to want to follow the steps. Also told to follow the instructions in CONTRIBUTING.md document to build Conjur

### Meeting 2
Continued trying to build Conjur<br>
When run in WSL the following error appeared (line endings CRLF):
- /usr/bin/env: ‘bash\r’: no such file or directory
- this error was resolved with using git bash

Running ./start (in git bash) resulted in the following error:
- /usr/bin/env: ‘ruby’: no such file or directory
- decided to solve line endings error before continuing

Before meeting, I tried to resolve the line endings error. Attempts 1 and 2 were found on the internet by Shlomo
Attempt 1:
>git config --global --edit <br>
git config --global core.eol lf <br>
git config --global core.autocrlf input<br>
git rm -rf --cached .<br>
git reset --hard HEAD<br>

Attempt 2: 
>add a file named .gitattributes <br>
*.txt text eol=lf <br>
Then run git add --renormalize .

Attempt 3: I got ChatGPT to write me a bash script that changed the line endings in each file from CRLF to LF
>#!/bin/bash
<br>
DIRECTORY=$1<br>
if [ -z "$DIRECTORY" ]; then<br>
  echo "Usage: $0 <directory>"<br>
  exit 1<br>
fi<br>
find "$DIRECTORY" -type f -exec sed -i 's/\r$//' {} \;<br>
echo "All files in $DIRECTORY converted to LF line endings."<br>

Running this file with ./convert_to_lf.sh "$(pwd)" did change all the line endings to LF, however also made it so github couldn't find the repository for some reason. Whenever I would delete the repository and try recloning and rerunning this script, it would just make the repository seemingly dissapear from my github desktop.

Attempt 4: git clone https://github.com/GheaCRPI/Conjur-RCOS-F24.git
Recloning the repository using the command line instead of github desktop seemed to resolve the issue

After I fixed this, I ran into another issue regarding ruby I think, this was fixed in meeting 3.

### Meeting 3
I do not remember the issue I initially fixed however, I got conjur built during this meeting and was able to set up the conjur environment. We began attempting to debug and downloaded Ruby LSP.

Attempted to learn to debug with VSCode, created a launch.json file in the .vscode folder 
> {<br>
    "version": "0.2.0",<br>
    "configurations": [<br>
        {<br>
            "name": "Listen for rdebug-ide",<br>
            "type": "ruby_lsp",<br>
            "request": "attach",<br>
            "remoteHost": "127.0.0.1",<br>
            "remotePort": "1234",<br>
            "remoteWorkspaceRoot": "/src/conjur-server"<br>
        }<br>
    ]<br>
}

It didn't work.

### Meeting 4
Helped Brian reclone the directory using the command line, got it built on his laptop. Attempted to start it however it kept timing out because it took too long. Tried running it on a VM but it didn't work either. (problem was later resolved by increasing the time allowed to run the program)

Continued trying to debug
- VSCode now cannot find RubyLSP
- I can't start RubyLSP for some reason now

### Meeting 5
Trying to fix Ruby LSP issues. We ran into a lot of issues regarding the version conflicts and were manually editing the GEM file to resolve these conflicts. We ran into a thing something that said PostgresSql  needed to be installed which took 20 minutes to install.

#### Between Meeting 5 and 6
I created a new branch for fix-warnings that was intended to pull down to the original branch for the next release of Conjur. During this I learned how to rebase commits into a single commit. I also had to configure my username and email and used a hidden email using a personal acces token. I also added a signoff message to my commit. 
- git config user.name "FirstName LastName"
- git config user.email "#######+GithubUsername@users.noreply.github.com"
- git rebase -i HEAD~2
- use PAT for the password
- git commit --amend --no-edit --signoff
- git push -f

### Meeting 6
We tried rebuilding Conjur using Git Bash instead of WSL. It worked for Brian but not me and I ran into an error that I was running into when we first tried building it. 
Error: /usr/bin/env: ‘ruby’: no such file or directory
We tried recloning it again into a seperate directory but now my git is messed up due to me having two instances of the repository on my desktop.
Running it with git bash cause conjur to time out after 90s, similar to how Brian's was taking too long a few weeks ago.

### Meeting 7
We talked about beginning to write test case and discussed possibly writing test cases on Summon. We discussed how Summon is used for pulling secrets from Conjur, and how to check what parts of the code are lacking unit tests. We can edit documentation for how Summon is used for Conjur and possibly edit the markdown file describing how to download Summon for windows. 

To run test cases:
- ./test_unit
- go tool cover -html=output/c.out

3 stages to tests: setup, action calling the function, checking if output was expected

In between meeting 7 and 8, I got summon downloaded successfully and began looking at the test cases. I figured out how to run thme on my own, and figured out which files correlated to what and began looking into writing my own. Also downloaded keyring for summon to use, however did not fully get that downloaded. Learned that Conjur is a provider for Summon, along with keyring.

### Meeting 8
Discussed the different parts of the test cases, and found out how to run and debug individual tests using Go. Also resolved my issue with keyring and got that properly downloaded. I plan on completing writing at least one unit test by the next meeting.

### Meeting 9
I met with Shlomo alone because Brian was busy, but he talked about how he had to reinstall Ruby LSP on a new laptop and things he did to fix the errors that he encountered. He said he resolved them by downloading Ruby rvm, or a ruby version manager because a lot of the issues I ran into while working with Ruby LSP were version issues so this might be a possible fix for the issue. He documented the changes and marked me as a co-author because we were trying to fix the error earlier in the semester. He also helped clarify how certain parts of Go worked. 

Additionally, this week a new update of Conjur came out, and both my commits were in it!

### Friday November 29
I got VSCode debugging functioning, and the Debugger says connected in the conjur environment. The process went way smoother than it did on my Windows laptop, I think this is because I used a Mac this time due to breaking my other laptop. It still says that there is a version issue, however in the terminal it says "DEBUGGER CONNECTED" which I am considering a success considering before it would spit out many errors and wouldn't ever get to that stage.

I've discovered that the Conjur installation process is way simpler on a Mac and also a lot more cooperative.