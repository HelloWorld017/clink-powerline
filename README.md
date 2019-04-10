# clink-powerline
An extendable powerline plugin for clink and cmder

----

## Installation
### From Bundle
Go to [release tab](https://github.com/HelloWorld017/clink-powerline/releases), download latest build, add it to clink profile directory.  
For cmder user, it is (cmder/config directory)

### From Source (For development)
Download source and link powerline.lua and powerline folder to clink profile directory.  
```
git clone https://github.com/HelloWorld017/clink-powerline.git
(move to clink profile directory)
mklink powerline.lua (source directory)/powerline.lua
mklink /d powerline (source directory)/powerline
```
**This method can occur a bug which says `could not find powerline`.**

## Screenshots
![Screenshot](https://i.imgur.com/Kuj6GdI.png)

## Included Sections
 * Currently Working Directory `cwd`  
 * Git `git`  
 * Lambda `lambda` (A lambda icon with indicator showing has admin privilege and is last command successful)  
 * Node `node` (Shows node version and package name)  
 * Time `time`  
 * Text `textseg` (A custom text)  
 * Plain Text `text` (Custom text, but not treated as section, the raw text is just appended)

## Editing Powerline
If you want to edit your powerline, please open lua file and find `Powerline.init`.  
There should be sections and you can add/remove sections and change order.  

You can add text instead of section. 

### Arguments and Colors
You can change colors of section by syntax like `sectionname/args:fg+bg`.

`fg` and `bg` are colors and follwing colors can be accepted.
```
black, red, green, yellow, blue, magenta, cyan, white,
lightBlack, lightRed, lightGreen, lightYellow, lightBlue, lightMagenta, lightCyan, lightWhite, default 
```

`args` are optional and used for `lambda` and `textseg`.  

#### Textseg / Text
	* When arguments are supplied to `textseg` or `text`, it will show the arguments.
#### Lambda
	* If you want to use admin check, you should follow the form of `text/rootText1`.  
		* `text/rootText2`, will check privilege everytime you enter but it is very laggy. Don't use this.  
		* If the cmd is running as administrator, the rootText will be shown instead of lambda. Otherwise, text will be shown instead of lambda.
	
	* If you don't want to use admin check, just supply any text not including `/` as arguments. The text will be shown instead of the lambda symbol.

### Examples
```lua
Powerline.init({"textseg/λ:black+yellow", "time:red+black", "cwd", "node", "git", "text/\n", "lambda/nenw*/root* ⚡1"})
```

## Bundling
I have made some change to [luapack](https://gist.github.com/turtleDev/a54a61a14e4a438f893865843279fd40) in order to build in Windows.  
You should need MinGW to build. (Maybe it comes with cmder)

In project directory, please execute command `lua bundler.lua powerline.lua`.  
It will be bundled in `dist/powerline.bundle.lua`.
