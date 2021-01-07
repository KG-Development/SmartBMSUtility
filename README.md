# SmartBMSUtility
This is the repository for my iOS App to connect with Xiaoxiang Smart BMS' 
### You can buy the bms here:
https://www.lithiumbatterypcb.com/

## Sponsors
If you want to help me keep apps like this alive and updated, please consider becoming a github sponsor. This will help to cover my Apple Developer expenses.

## Status:
iOS: [v1.0.2](https://apps.apple.com/de/app/apple-store/id1540178292)<br>
macOS: [v1.0.2](https://apps.apple.com/de/app/apple-store/id1540178292)

## About this repository
This repository is intended to track issues and minor feature requests. I have removed any relevant file from my Xcode workspace to avoid users compiling it for their own use, as I intend to sell this tool for $0.49.

## Contributing
You can contribute to this project by submitting untested code changes that I will test with my workspace.
To contribute to this project and test it with the whole project, I can give you access to my private repository if you can prove that you have a current Apple developer license. This requirement could be waived, as it only serves to prevent other users from compiling for themselves.
Contact me by e-mail, Discord @NeariX#4799 or Twitter (link in my profile) to gain access to my private repository containing all code.

# To-Do:
- [ ] LiFePo support
- [ ] Logging
- [ ] Configuration
- [ ] Stability improvements (Reconnect device for example)
- [x] MacOS support
- [ ] Add more languages
- [ ] Fancy UI
- [ ] iOS 14 Widget

# FAQ
### I can't find my device in my app?
The app searches for nearby devices with specific characteristics. If your Smart BMS offers different characteristics it will not display it. You can help me resolving this issue by sending me details about your BMS and its bluetooth characteristics.

### Can I configure my BMS with this app?
Not yet. I am currently working on it. This feature will come in version 1.1.0, I expect to release this version in mid january.
Version 1.1.0 early beta can be downloaded through testflight here: https://testflight.apple.com/join/YWdbkZ8s

### What's up with the GPS features in this App?
Originally I wanted an iOS application to track my efficiency and the range of my electric scooter. So I contacted @smagicld to help him add this feature to his application, and he rejected it. Since it would be a waste of time and effort to make this application just for me, I decided to make it public, open source and as user-centric as possible. If your current use case needs a specific feature in the application, let me know, I will be happy to help implement your application.
You should be able to use this application on your electric bicycle to see the current energy consumption, the energy use per kilometer/mile and the expected remaining range based on your current energy consumption and GPS speed.
