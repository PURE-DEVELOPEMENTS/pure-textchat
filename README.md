# Pure TextChat

A text communication system for RedM that allows players to display text messages above their character's head with typing animations.

## Features

- **Text Display**: Messages appear as floating text above player heads
- **Typing Animation**: Realistic notebook writing animation while typing
- **Configurable Settings**: Customizable text appearance, duration, and distance
- **User-Friendly UI**: Clean, modern interface for message input
- **Bulgarian Language Support**: UI text in Bulgarian
- **Character Limit**: Configurable message length limits (default: 100 characters)

## Installation

1. Download the resource
2. Place it in your RedM `resources` folder
3. Add `ensure pure-textchat` to your `server.cfg`
4. Restart your server

## Configuration

Edit `config.lua` to customize the text chat behavior:

```lua
Config.TextSettings = {
    scale = 0.3,           -- Text size
    color = {255, 255, 255, 215}, -- RGB + Alpha
    duration = 5000,       -- Duration in milliseconds (5 seconds)
    distance = 15.0,       -- Distance from which text is visible
    height_offset = 1.2    -- Height above player's head
}

Config.UISettings = {
    max_length = 100,      -- Maximum characters per message
    placeholder = "Напишете съобщение..."
}
```

## Usage

Players can activate the text chat system through in-game commands or keybinds (implementation depends on your server setup). When activated:

1. A UI window opens for message input
2. Players can type their message (up to 100 characters by default)
3. While typing, the character performs a notebook writing animation
4. Once sent, the message appears as floating text above the player's head
5. The message remains visible for 5 seconds (configurable)

## File Structure

```
pure-textchat/
├── client/
│   └── main.lua          # Client-side logic and animations
├── server/
│   └── main.lua          # Server-side message handling
├── html/
│   ├── index.html        # UI structure
│   ├── style.css         # UI styling
│   └── script.js         # UI functionality
├── config.lua            # Configuration settings
└── fxmanifest.lua        # Resource manifest
```

## Version

**1.0.0** - Fully working on RSG V2

## Requirements

- RedM Server
- Compatible with RSG V2

## License

This resource is provided as-is. Please respect the original author's work.