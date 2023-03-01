# SmartBMSUtility
This is the repository for my iOS App to connect with Xiaoxiang (JBD) Smart BMS' 
### You can buy the bms here:
https://www.lithiumbatterypcb.com/<br>
https://overkillsolar.com/

## Sponsors
If you want to help me keep apps like this alive and updated, please consider becoming a github sponsor or leaving as much as you want on my paypal. This will help to cover my Apple Developer expenses of 99$ a year.

## Status:

#### iOS: [v2.0.1](https://apps.apple.com/de/app/apple-store/id1540178292)<br>
#### macOS: [v1.2.2](https://apps.apple.com/de/app/apple-store/id1540178292)

#### [Changelog](https://github.com/NeariX67/SmartBMSUtility/blob/main/changelog.md)


## Known issues:
### LionTron batteries can't be configured
This is because liontron uses a hardware password. If you know this password, you can enter it in the app (version 2 or newer) 


## About this repository
This repository is intended to track issues and minor feature requests. I have removed any relevant file from my Xcode workspace to avoid users compiling it for their own use, as I intend to sell this tool.
I am currently not planning to publish v2's source code for that same reason.

## Contributing
You can contribute to this project by submitting untested code changes that I will test with my workspace.
To contribute to this project and test it with the whole project, I can give you access to my private repository if you can prove that you have a current Apple developer license. This requirement could be waived, as it only serves to prevent other users from compiling for themselves.
Contact me by e-mail, Discord @NeariX#4799 or Twitter (link in my profile) to gain access to my private repository containing all code.

Make sure to check out [Discussions](https://github.com/NeariX67/SmartBMSUtility/discussions) where I'm willing to help you.


# FAQ
### I can't find my device in my app?
The app searches for nearby devices with specific characteristics. If your Smart BMS offers different characteristics it will not display it. You can help me resolving this issue by sending me details about your BMS and its bluetooth characteristics.

### Can I configure my BMS with this app?
Yes, you can configure your BMS with this app, make sure to come back and report any issues when found.

### Can i help this app by becoming a beta tester?
Yes of course. I have made a [TestFlight](https://testflight.apple.com/join/YWdbkZ8s) which you can join.

### What's up with the GPS features in this App?
Originally I wanted an iOS application to track my efficiency and the range of my electric scooter. So I contacted @smagicld to help him add this feature to his application, and he rejected it. Since it would be a waste of time and effort to make this application just for me, I decided to make it public, open source and as user-centric as possible. If your current use case needs a specific feature in the application, let me know, I will be happy to help implement your application.
You should be able to use this application on your electric bicycle to see the current energy consumption, the energy use per kilometer/mile and the expected remaining range based on your current energy consumption and GPS speed.
