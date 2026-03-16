# git-poster

A Claude Code plugin that generates creative poster-style visualizations of git contributions using [Nano Banana MCP](https://github.com/bartadaniel/nano-banana-mcp).

Turn your git stats into stunning artwork across 17 different artistic styles — from NASA mission posters to medieval manuscripts, anime battle scenes to vintage pinball machines.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (v1.0.33+)
- [Nano Banana MCP](https://github.com/bartadaniel/nano-banana-mcp) configured with a [Gemini API key](https://aistudio.google.com/apikey)

If you already have Nano Banana MCP set up, the plugin works immediately — no extra configuration needed. If not, the plugin will guide you through setup on first run.

## Installation

```bash
/plugin marketplace add bartadaniel/claude-plugins
/plugin install git-poster@bartadaniel-plugins
```

## Usage

```
/git-poster:viz [author_name] [--days=N] [--style=STYLE]
```

- **author_name** — Git author to visualize (defaults to `git config user.name`)
- **--days=N** — Days of history to analyze (default: 365)
- **--style=STYLE** — Poster style (see below). Omit to see the interactive menu.

### Examples

```
/git-poster:viz                           # Your stats, pick a style
/git-poster:viz --style=nasa              # NASA mission poster
/git-poster:viz "Jane Doe" --days=90      # Specific author, last 90 days
/git-poster:viz --style=bmovie,ukiyoe     # Generate multiple styles
```

## Available Styles

| Style | Description |
|-------|-------------|
| `rpg` | Fantasy RPG character sheet — D&D style with stats, skills, equipment |
| `wpa` | WPA / New Deal national parks poster — bold flat colors, heroic aesthetic |
| `lucha` | Lucha libre wrestling poster — neon pinks, golds, fight card format |
| `bmovie` | 1950s B-movie sci-fi poster — giant code monster, ray guns |
| `circus` | Vintage carnival/circus poster — ringmaster, death-defying commits |
| `ukiyoe` | Japanese Edo-period woodblock print — samurai vs yokai tech debt |
| `funk` | 70s blaxploitation/funk poster — leather jacket, explosions |
| `mucha` | Art Nouveau / Alphonse Mucha — flowing code vines, floral borders |
| `boxing` | Vintage boxing match poster — tale-of-the-tape stats |
| `nasa` | NASA / Space Race mission poster — retro 1960s, mission patches |
| `manuscript` | Medieval illuminated manuscript — monk's codex, gold leaf |
| `tarot` | Major arcana tarot card — mystical figure, cosmic symbolism |
| `stained` | Gothic cathedral stained glass — multi-panel saga, jewel tones |
| `pinball` | Vintage 1970s pinball machine — circuit board playfield |
| `cyberpunk` | Cyberpunk neon dashboard — holographic HUD, data viz |
| `anime` | Anime battle scene — slaying code monsters, speed lines |
| `renaissance` | Renaissance oil painting — Sistine Chapel style |

## Example Output

### 1950s B-Movie Poster
![B-movie style poster](examples/bmovie.png)

### Vintage Circus Poster
![Circus style poster](examples/circus.png)

### Lucha Libre Wrestling Poster
![Lucha libre style poster](examples/lucha.png)

## How It Works

1. **Collects git stats** — commits, lines changed, streaks, peak hours, file types, project areas, and more
2. **Builds a developer profile** — synthesizes stats into a structured summary with ranks, rhythms, and achievements
3. **Generates a poster** — feeds the profile into a style-specific prompt template and generates artwork via Nano Banana MCP

All stats are real — exact numbers from your git history, woven into the visual narrative.

## License

MIT
