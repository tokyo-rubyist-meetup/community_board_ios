community_board_ios
===================

See the companion slides at:
http://www.slideshare.net/gillygize/connecting-to-a-rest-api-in-ios

## Install Dependencies

### Xcode 4.6.1

Xcode can be install via the OSX App Store.

### git
Git is a distributed version control system. Your computer most likely has it installed. If you are unsure, you can confirm by typing git. If you don't have it installed, you can get it from Git's home page.

### CocoaPods
[CocoaPods](http://cocoapods.org/) is used for managing dependencies. Install it with

```
[sudo] gem install cocoapods
pod setup
```


## Setup the Application

From the terminal, 

```
git clone git://github.com/tokyo-rubyist-meetup/community_board_ios.git
cd community_board_ios
pod install
open CommunityBoard.xcworkspace
```

* Make sure the build target is set to community board
* Press the run button
* The simulator should launch with the application
