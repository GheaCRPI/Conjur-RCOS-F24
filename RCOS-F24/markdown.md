9/24

* First meeting with Schlomo  
* Discussed the purpose of the project, what we are intended to do and explained the basics of what we are dealing with, like kubernetes.

10/1

* Second meeting with Schlomo  
* Downloaded docker and attempted to build the conjur system itself  
* Ran into a few issues and warnings that we have to figure out

10/8

* Third meeting with Schlomo  
* Attempted to build the Conjur system again  
* Still ran into some issues but found a fix


10/15

* While Ghea was able to build  the machine, I was not so I had to figure that out  
* Tried to debug some more stuff

10/22

* Finally able to figure out how to build the machine  
* Started to find some more issues when trying to do ./build and ./start

10/29

* Ran into issues with ruby and getting it to run and download  
* Attempted to fix those issues in order to build conjur effectively

11/5

* Discussed writing test cases and saw a few examples  
* Schlomo introduced us to summon

Some issues we ran into was building the machine itself. Since Conjur was mainly built and ran using macs, Ghea and I were struggling to run it on windows. The initial issue was some of the endings were not correct to run on windows/wsl, but we figured that out. A future issue that I encountered after we fixed the ending problems, was when re I tried to run it would timeout after 90 seconds. To fix this I increased the timer.