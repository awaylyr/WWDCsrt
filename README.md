  ![icon](./WWDCSubGetter/Assets.xcassets/AppIcon.appiconset/Icon_256x256.png)

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
	    <img src="https://img.shields.io/badge/Version-1.5.0-brightgreen.svg?style=flat" alt="Swift 4.0">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
	    <img src="https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat" alt="Swift 4.0">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat" alt="Platform iOS | macOS">
</a>
    <a href="https://twitter.com/ssamadgh" target="_blank">
        <img src="https://img.shields.io/badge/Twitter-@ssamadgh-blue.svg?style=flat" alt="ssamadgh Twitter">
    </a>
    </a>
    <a href="https://www.linkedin.com/in/ssamadgh" target="_blank">
        <img src="https://img.shields.io/badge/Linkedin-ssamadgh-blue.svg?style=flat" alt="ssamadgh Linkedin">
    </a>
</p>

</p>

# 备注

其他部分都是原作者的介绍，这部分简单说一下我增加的功能：

- 导出中英文双语字幕文件
  ![Text File](./ScreenShots/video.png)

- 导出中英文双语抄本

  ![Text File](./ScreenShots/wwdcsrt.gif)

- 在`Releases/`目录下有一份所有session的导出文件


# WWDC.srt
#### An app for Download WWDC subtitles

### Whats New: 

**version 1.5.1:**

- Now supports WWDC 2018 video's links

- Now you can get links of videos, pdfs and sample codes for each session you want and even for all sessions at once!

- Now the app opens the destination address of your desired data in finder, after downloading them.

- Some minor bugs fixed


**version 1.0.1:**
	
- Now supports Fall 2017 video's links

## Intro
WWDC.srt allows you to download subtitle for each WWDC session video since 2013 in (**srt**) format.

⬇️ If you just want to download the latest release, go to [this link](./Releases/WWDC.srt.zip).

## Session

In this tab you can choose ( or search session number of ) your favorite WWDC Session video from the list and download it's subtitle or data links by clicking get button. Also you can download all sessions subtitles or data links alltogether by choosing (All Sessions) radio button.
Data links are include videos links (HD or SD depending on your choice), pdf links and sample code links.

![Session](./ScreenShots/Session01.png)


![Session](./ScreenShots/Session02.png)


## Video Link

In this tab you can paste WWDC video link like:

 ` https://devstreaming-cdn.apple.com/videos/tutorials/20170912/201qy4t11tjpm/building_apps_for_iphone_x/building_apps_for_iphone_x_hd.mp4?dl=1 `

  into text field and download it's subtitle.

  ![Video Link](./ScreenShots/VideoLink.png)


## Text File

In this tab you can just drag a text file which contains a bunch of your favorite WWDC Video's links into the view and download their subtitles altogether.

  ![Text File](./ScreenShots/TextFile.png)

## Building the app

**Building requires Xcode 9 or later.**

Just clone this branch and run the project in xcode 9.
