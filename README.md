<h1 align="center">Welcome to Coffee Button 👋</h1>
<p>
  <a href="https://www.gnu.org/licenses/gpl-3.0.html" target="_blank">
    <img alt="License: GPL 3" src="https://img.shields.io/badge/License-GPL 3-yellow.svg" />
  </a>
</p>

> Order your coffee in one click or everything else  
> Click the button, the raspberry boot, call your webhook then shutdown

## Prototype

![Prototype](images/prototype.png "Prototype")

## Install

### What you need to run the project

 - a Raspberry Pi with Wifi, or ethernet connection if you like cables
 - an SD card
 - 2 leds with 330Ω resitors and cables
 - a push button with cables
 - optionnaly a breadboard, to check the connections before soldering the elements

### How to build

Connect the push button on pins 5 & 6 _(SCL & Ground)_, so the click will wake it.
Connect the green led and a resitor on pins 32 & 34 _(PWM0 & Ground)_.
Connect the red led and the other resistor on pins 12 & 14 -(PWM0 & Ground)_.

![GPIO connectors](images/Raspberry-GPIO-Pinout.png "GPIO connectors")

Add a line to call the `init.sh` file from your boot `/etc/rc.local` on raspbian lite

## Usage

```
cp .env.example .env
Replace in .env with your webhook service 
# TODO explain the build?
```

## Author

👤 **Jérémy Lejeune**

* Github: [@yodur2potassium](https://github.com/yodur2potassium)

👤 **Lucas Dupuy**

* Github: [@louckousse](https://github.com/louckousse)

## Show your support

Give a ⭐️ if this project helped you!

## 📝 License

Copyright © 2019 [Jérémy Lejeune](https://github.com/yodur2potassium), [Lucas Dupuy](https://github.com/louckousse).<br />
This project is [GPL 3](https://www.gnu.org/licenses/gpl-3.0.html) licensed.

***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_

