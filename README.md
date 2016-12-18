# My PowerShell Profile

I used windows for years. Admin. Developer. Gamer. Along the way I used SunOS, Solaris, RedHat, Ubuntu and MacOS. My .bashrc project is even [here on github](https://github.com/SteveHartzog/config) - though I haven't touched it in 11 mos ,(so far - but maybe again someday when Apple starts innovating again).

I've been on both sides of the camp and now I'm using Windows 10... which is really, really good. The Bash on Ubuntu on Windows on My Computer on a Thursday, (beta edition)... is great, but... really? Beta for 6mos?! This should be done already. Also, my beta broke and I have to reinstall it to get it functional again (sudo fails). Sigh. So I thought - why not try implementing some basic Posix commands? I sat down over the 16 Dec 2016 weekend I started hacking together a new prompt and ls command (with output similar to real ls). It's not perfect, but hey - it's for fun. Maybe I'll even clean it up and put it on the powershell gallery someday.

1. ls alias to a new Get-Posix-ls
   - So far it looks similar. Kind of like the bash on ubuntu ls, similar but not the same. I intend to make it the same. :)
   - Next up, get integration with colors or stars in the file name.
   - Plus like, actual colors. Console's have a limited selection but it's better than nothing.
2. Way better prompt. Like epic level.
   - No "PS >" crap. A real prompt.
   - 2-lines
     - user@device:/\<dir\> (\<files\_in\_dir\>)
     - [\<command#\>] $ <cursor\_block>
   - Home dir is even a ~ :)
   - I might add the git integration here?
3. Copied the invoke-speech (aka out-voice) from somebody (lots of people seem to have done it but I can't figure out where I copied it from)
   - Yeah, I basically just scarfed this since it was so cool. Not sure how/where to use it. Possibly in builds. You know: "Job's Done!" [said like a grunt from Warcraft] Of course I get plenty of pings when it bombs. ¯\\\_(ツ)\_/¯