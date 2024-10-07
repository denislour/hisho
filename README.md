# Hisho

[![Crystal Build and Test](https://github.com/denislour/hisho/actions/workflows/crystal.yml/badge.svg)](https://github.com/denislour/hisho/actions/workflows/crystal.yml)

Hisho is a command-line interface (CLI) tool inspired by Aider, designed to interact with AI models from OpenRouter.ai. Built with Crystal, Hisho aims to provide a seamless and efficient way to communicate with various AI models directly from your terminal.

## Features

- Connect to OpenRouter.ai models with ease
- Simple setup requiring only a model name and OpenRouter.ai API key
- Interactive command-line interface for natural conversations with AI
- Written in Crystal for performance and type safety
- Extensible architecture allowing for easy addition of new features

## Installation

### Prerequisites

1. Install Crystal:

   For macOS using Homebrew:

   ```
   brew install crystal
   ```

   For Ubuntu:

   ```
   curl -fsSL https://crystal-lang.org/install.sh | sudo bash
   ```

   For other operating systems, please refer to the [official Crystal installation guide](https://crystal-lang.org/install/).

2. Clone the repository:

   ```
   git clone https://github.com/denislour/hisho.git
   cd hisho
   ```

3. Install dependencies:
   ```
   shards install
   ```

## Configuration

Create a `.env` file in the project root with your OpenRouter.ai API key and preferred model:

## Usage

```
crystal build src/main.cr -o hisho
./hisho
```

## Contributing

1. Fork it (<https://github.com/denislour/hisho/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Lektor](https://github.com/your-github-user) - creator and maintainer
