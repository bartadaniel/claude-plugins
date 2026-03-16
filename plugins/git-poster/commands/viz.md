---
description: Generate creative visualizations of git contributions using Nano Banana
argument-hint: "[author_name] [--days=N] [--style=rpg|wpa|lucha|bmovie|circus|ukiyoe|funk|mucha|boxing|nasa|manuscript|tarot|stained|pinball|cyberpunk|anime|renaissance]"
---
# Git Contribution Visualizer

Generate creative poster-style visualizations of a developer's git contributions using the Nano Banana MCP image generation tools.

**Arguments:**
- `$ARGUMENTS` — Optional. Format: `[author_name] [--days=N] [--style=STYLE]`
  - `author_name`: Git author name to visualize. Defaults to `git config user.name`.
  - `--days=N`: Number of days of history to analyze. Default: 365.
  - `--style=STYLE`: Poster style to generate (see styles below). If omitted, show the menu.

## Available Styles

| Style | Description |
|-------|-------------|
| `rpg` | Fantasy RPG character sheet — D&D style with stats, skills, equipment, defeated tech debt dragon |
| `wpa` | WPA / New Deal national parks poster — bold flat colors, heroic worker aesthetic |
| `lucha` | Lucha libre wrestling championship poster — neon pinks, golds, dramatic mask, fight card |
| `bmovie` | 1950s B-movie sci-fi poster — giant code monster, terrified onlookers, ray guns |
| `circus` | Vintage carnival/circus poster — ringmaster, death-defying commits, lion taming bugs |
| `ukiyoe` | Japanese Edo-period ukiyo-e woodblock print — samurai vs yokai tech debt |
| `funk` | 70s blaxploitation/funk movie poster — leather jacket, explosions, funky typography |
| `mucha` | Art Nouveau / Alphonse Mucha — flowing organic code vines, ornate floral borders |
| `boxing` | Vintage boxing match poster — tale-of-the-tape stats, fight card format |
| `nasa` | NASA / Space Race mission poster — retro 1960s, mission patches, launch stats |
| `manuscript` | Medieval illuminated manuscript — monk's codex, gold leaf, marginalia illustrations |
| `tarot` | Major arcana tarot card — mystical figure, dual weapons, cosmic symbolism |
| `stained` | Gothic cathedral stained glass window — multi-panel saga, jewel tones |
| `pinball` | Vintage 1970s pinball machine — circuit board playfield, bumpers, flippers |
| `cyberpunk` | Cyberpunk neon dashboard — holographic HUD, rain-soaked city, data viz |
| `anime` | Anime battle scene — slaying code monsters, spirit orbs, speed lines |
| `renaissance` | Renaissance oil painting — Sistine Chapel style, creation of the codebase |

## Steps

### Step 0: Check for Nano Banana MCP

Before doing anything else, verify that the Nano Banana MCP tools are available by checking if `mcp__nano-banana__generate_image` exists. If the tools are not available, stop immediately and tell the user:

> Nano Banana MCP is not available. This plugin requires it for image generation.
>
> 1. Get a free Gemini API key from https://aistudio.google.com/apikey
> 2. Add to your shell profile: `export GEMINI_API_KEY="your-key-here"`
> 3. Restart Claude Code
>
> For full setup instructions, see: https://github.com/bartadaniel/nano-banana-mcp

Do NOT proceed to any further steps if the tools are missing.

### Step 1: Parse Arguments

Parse `$ARGUMENTS` for author name, `--days`, and `--style`. Apply defaults:
- Author: `git config user.name`
- Days: 365
- Style: show menu to user

### Step 2: Collect Git Stats

Run ALL of the following git commands in parallel where possible to build a comprehensive developer profile. Use the parsed author name and days values.

```bash
# Core stats
git log --author="AUTHOR" --since="DAYS days ago" --oneline | wc -l
git log --author="AUTHOR" --since="DAYS days ago" --pretty=format:"%H" | xargs -I{} git diff-tree --no-commit-id --numstat {} 2>/dev/null | awk '{add+=$1; del+=$2; files++} END {printf "files_changed=%d\nlines_added=%d\nlines_deleted=%d\nnet_lines=%d\n", files, add, del, add-del}'
git log --author="AUTHOR" --since="DAYS days ago" --format="%ad" --date=format:"%Y-%m-%d" | sort -u | wc -l

# Streak (use python3)
git log --author="AUTHOR" --since="DAYS days ago" --format="%ad" --date=format:"%Y-%m-%d" | sort -u | python3 -c "
import sys
from datetime import datetime, timedelta
dates = sorted(set(datetime.strptime(l.strip(), '%Y-%m-%d') for l in sys.stdin if l.strip()))
max_streak = streak = 1
for i in range(1, len(dates)):
    if dates[i] - dates[i-1] == timedelta(days=1):
        streak += 1
        max_streak = max(max_streak, streak)
    else:
        streak = 1
print(f'longest_streak={max_streak}')
"

# Patterns
git log --author="AUTHOR" --since="DAYS days ago" --format="%ad" --date=format:"%Y-%m-%d" | sort | uniq -c | sort -rn | head -5   # busiest days
git log --author="AUTHOR" --since="DAYS days ago" --format="%ad" --date=format:"%Y-%m" | sort | uniq -c | sort -k2               # monthly distribution
git log --author="AUTHOR" --since="DAYS days ago" --format="%ad" --date=format:"%A" | sort | uniq -c | sort -rn                   # day of week
git log --author="AUTHOR" --since="DAYS days ago" --format="%ad" --date=format:"%H" | sort | uniq -c | sort -rn | head -8         # peak hours

# Work breakdown
git log --author="AUTHOR" --since="DAYS days ago" --pretty=format:"%H" | xargs -I{} git diff-tree --no-commit-id --numstat {} 2>/dev/null | awk '{print $3}' | grep -oE '\.[^./]+$' | sort | uniq -c | sort -rn | head -10   # file types
git log --author="AUTHOR" --since="DAYS days ago" --pretty=format:"%H" | xargs -I{} git diff-tree --no-commit-id --numstat {} 2>/dev/null | awk '{print $3}' | sed 's|/[^/]*$||' | sort | uniq -c | sort -rn | head -15   # top directories

# Commit message analysis — get raw messages for the agent to analyze
git log --author="AUTHOR" --since="DAYS days ago" --pretty=format:"%s" | head -200   # recent commit messages

# Weekend and late-night commits
git log --author="AUTHOR" --since="DAYS days ago" --format='%ad' --date=format:'%u' | awk '$1>=6' | wc -l   # weekend commits
git log --author="AUTHOR" --since="DAYS days ago" --format='%ad' --date=format:'%H' | awk '$1>=21 || $1<7' | wc -l   # late night commits

# Team context
git shortlog -sn --all --since="DAYS days ago" | head -10   # leaderboard for rank
```

### Step 3: Build Developer Profile

Synthesize all collected stats into a structured profile summary. Include:

- **Core**: total commits, active days, longest streak, lines added/deleted/net
- **Rank**: position on team leaderboard (note if #1 is a bot)
- **Rhythm**: dominant day of week, peak hours, busiest single day, hottest month
- **Character**: analyze the raw commit messages to categorize the developer's work (e.g., fixes, features, refactoring, cleanup, etc.). Adapt to whatever commit style the repo uses — conventional commits, freeform, ticket-prefixed, etc.
- **Domains**: identify project areas from commit messages and top directories. Look for ticket prefixes, component names, or recurring themes — whatever patterns exist in this specific repo.
- **Tech stack**: file type breakdown
- **Achievements**: look for PRs (e.g., `(#123)`), ticket references, hotfix-related commits, weekend/late-night commits. Adapt the detection to the repo's actual conventions.
- **Biggest moment**: hottest month's commit count, busiest single day

Print this profile summary to the user before generating images.

### Step 4: Style Selection

If `--style` was provided, use that style. Otherwise, present the full style menu to the user and ask them to pick one or more (comma-separated). They can also say "all" to generate all styles, or "random" to pick 3 at random.

### Step 5: Generate Images

For each selected style, construct a detailed image generation prompt using the Nano Banana MCP (`mcp__nano-banana__generate_image`). Use 2K size.

**CRITICAL PROMPT GUIDELINES:**
- Weave ALL the real stats into the visual narrative (exact numbers, not approximations)
- Include the developer's name prominently
- Map stats to visual metaphors appropriate to the style
- Include top 3-5 most interesting/unique data points as visual callouts
- Use 3:4 aspect ratio for portrait styles (rpg, lucha, mucha, boxing, tarot, manuscript)
- Use 16:9 aspect ratio for landscape styles (bmovie, anime, cyberpunk, renaissance)
- Use 3:4 for vertical styles (wpa, circus, funk, nasa, stained, pinball)

Below are prompt templates for each style. Replace ALL placeholders with actual stats from the profile.

---

#### `rpg` — Fantasy RPG Character Sheet

> A fantasy RPG character sheet card for a developer named {NAME}, class: Code Paladin, Level {COMMITS}. Richly illustrated in detailed painterly fantasy art style. The character wears heavy plate armor forged from circuit boards and keyboard keys with glowing cyan runes, wielding a massive flaming sword engraved with "{FIXES} FIXES" in one hand and a radiant shield inscribed "{FEATURES} FEATURES" in the other.
>
> STATS panel: STR {COMMITS} (commits), DEX {ACTIVE_DAYS} (active days), INT {LINES_ADDED} (lines forged), WIS {LINES_DELETED} (lines purged), CON {HOTFIXES} (hotfixes survived), CHA #{RANK} (team rank)
>
> SKILLS: Top 3-4 domain areas as skill bars with percentages based on relative commit volume.
>
> SPECIAL ABILITIES: "{BEST_DAY_NAME} Fury" (+{BEST_DAY_COMMITS} commit bonus), "Peak Hours Surge" ({PEAK_HOURS} power spike), "{HOTTEST_MONTH} Volcanic" ({HOTTEST_MONTH_COMMITS} commits), "The Great Purge" ({NET_LINES} net lines)
>
> EQUIPMENT: Weapon: Sword of {PRS} Merged PRs, Armor: Plate of {TICKETS} Tickets Resolved, Ring: {STREAK}-Day Streak Ring
>
> At his feet lies a defeated dragon labeled "TECHNICAL DEBT". Behind him a castle city made of code. The sky shows {COMMITS} golden stars. Rich fantasy RPG art, ornate card border with gold filigree. Aspect ratio 3:4.

---

#### `wpa` — WPA / New Deal Poster

> A vintage 1930s WPA national parks style poster. Bold flat colors (earth tones, deep blue, orange). A heroic figure of {NAME} stands before a vast landscape where mountains are shaped like commit graphs — the tallest peak labeled "{HOTTEST_MONTH}: {HOTTEST_MONTH_COMMITS} COMMITS". Rivers of code flow through valleys labeled with domain areas. A rising sun radiates behind the figure. Bold sans-serif text at top: "VISIT THE CODEBASE" and at bottom: "MAINTAINED BY {NAME} — {COMMITS} COMMITS — {LINES_DELETED} LINES CLEARED — {PRS} TRAILS BLAZED". A banner reads "{ACTIVE_DAYS} DAYS OF SERVICE". Flat graphic style, limited color palette, screen print aesthetic. Aspect ratio 3:4.

---

#### `lucha` — Lucha Libre Wrestling Poster

> A vibrant lucha libre wrestling championship poster. {NAME} as a masked luchador "EL PURGADOR" in a dramatic pose, wearing a cyan and gold mask with circuit patterns. Fight card format. Main event: "{NAME} 'EL PURGADOR' ({COMMITS}-0) vs TECHNICAL DEBT (81K LINES)". Undercard bouts: "{FIXES} FIXES vs THE BUG SWARM", "{FEATURES} FEATURES vs LEGACY CODE". Stats as tale-of-the-tape: Height: {LINES_ADDED} lines forged, Weight: {LINES_DELETED} lines purged, Reach: {PRS} PRs merged, Record: {STREAK}-day streak. "{BEST_DAY_NAME} NIGHT SHOWDOWN — {PEAK_HOURS}". Neon pink, gold, black, hot magenta. Bold Mexican wrestling poster typography. Aspect ratio 3:4.

---

#### `bmovie` — 1950s B-Movie Poster

> A 1950s sci-fi B-movie poster. "ATTACK OF THE {LINES_DELETED} DELETED LINES!" in dramatic horror font at the top. A colossal monster made of tangled spaghetti code and error messages towers over a city (the codebase). {NAME} stands in the foreground with a ray gun, heroically defending the city. Terrified onlookers (junior devs) flee. Tagline: "ONE MAN. {COMMITS} COMMITS. {TICKETS} TICKETS. THE CODEBASE WILL NEVER BE THE SAME." Bottom credits: "Starring {NAME} as THE PURGER. {PRS} PRs of DESTRUCTION. {HOTFIXES} EMERGENCY DEPLOYMENTS." Vintage pulp illustration, faded colors, dramatic lighting. Aspect ratio 16:9.

---

#### `circus` — Vintage Circus Poster

> A vintage 1920s circus and carnival poster. "COME ONE, COME ALL! THE GREATEST CODE SHOW ON EARTH!" {NAME} as a dashing ringmaster in top hat and tails, cracking a whip made of fiber optic cables. Around him: an acrobat troupe of {PRS} PRs flying through the air, a strongman lifting {LINES_ADDED} lines overhead, a lion tamer subduing a beast labeled "TECHNICAL DEBT", a knife thrower hitting {TICKETS} ticket targets. Banner: "{COMMITS} DEATH-DEFYING COMMITS! {HOTFIXES} HOTFIXES WITHOUT A NET! {STREAK}-DAY ENDURANCE RECORD!" Ornate Victorian typography, warm reds and golds, weathered poster texture. Aspect ratio 3:4.

---

#### `ukiyoe` — Japanese Ukiyo-e Woodblock Print

> A traditional Japanese Edo-period ukiyo-e woodblock print. {NAME} depicted as a legendary samurai in ornate armor, drawing a katana mid-slash against a massive multi-headed yokai demon representing technical debt. Each head is a different code evil. Great waves of TypeScript code crash around them in the style of Hokusai. Mount Fuji in the background is made of {COMMITS} stacked commits. Cherry blossoms carry stats: {LINES_ADDED} lines forged, {LINES_DELETED} lines purged. Traditional flat perspective, bold black outlines, muted indigos and earth tones, visible woodgrain texture. Cartouche text boxes contain stats. Aspect ratio 3:4.

---

#### `funk` — 70s Blaxploitation / Funk Movie Poster

> A 1970s blaxploitation funk movie poster. "THEY DELETED HIS CODE. HE DELETED {LINES_DELETED} LINES BACK." {NAME} in a leather jacket and shades, standing cool in front of a massive explosion of deleted code. Funky psychedelic typography. "THE PURGER" in huge groovy letters. Credits: "{COMMITS} commits of non-stop action. {PRS} merges of fury. {HOTFIXES} emergency fixes." Tagline: "Every {BEST_DAY_NAME} at {PEAK_HOURS}, the code gets clean." Bold oranges, browns, yellows. Retro halftone print texture. Aspect ratio 3:4.

---

#### `mucha` — Art Nouveau / Alphonse Mucha

> An Art Nouveau poster in the style of Alphonse Mucha. {NAME} as an ethereal figure seated in a flowing organic arch made of intertwined code vines and circuit tendrils. Ornate floral borders contain stats in elegant serif text: {COMMITS} commits, {LINES_ADDED} lines cultivated, {LINES_DELETED} lines pruned. Flowing hair merges with streams of TypeScript. Halo of {PRS} merged PRs. Muted golds, soft pastels, sage greens, dusty roses. Intricate decorative panels show domain areas as seasonal motifs. Lithograph texture, delicate linework. Aspect ratio 3:4.

---

#### `boxing` — Vintage Boxing Match Poster

> A vintage boxing match fight night poster. "THE MAIN EVENT — {BEST_DAY_NAME} NIGHT AT THE REPO". Two fighters face off: {NAME} "THE PURGER" ({COMMITS}-0-{HOTFIXES}) vs LEGACY CODE (81K lines of pain). Tale-of-the-tape comparison: Commits {COMMITS}, PRs {PRS}, Streak {STREAK} days, Lines Purged {LINES_DELETED}, Tickets Closed {TICKETS}. Undercard: "{FIXES} FIXES vs BUG BATTALION" and "{FEATURES} FEATURES vs FEATURE REQUESTS". "LIVE FROM THE {HOTTEST_MONTH} ARENA — {HOTTEST_MONTH_COMMITS} ROUNDS". Old-school sepia boxing poster with red and gold accents, hand-drawn illustration style. Aspect ratio 3:4.

---

#### `nasa` — NASA / Space Race Mission Poster

> A retro 1960s NASA space program mission poster. "MISSION: CODEBASE — YEAR ONE REPORT". Commander {NAME} in a vintage spacesuit standing before a rocket labeled "DEVELOP" on the launchpad. Mission stats on control panels: {COMMITS} successful launches, {PRS} orbital insertions, {HOTFIXES} emergency re-entries, {TICKETS} missions completed. Mission patches on the side for each domain area. A trajectory arc shows monthly commits as waypoints. "LONGEST MISSION: {STREAK} CONSECUTIVE DAYS". "{HOTTEST_MONTH}: {HOTTEST_MONTH_COMMITS} LAUNCHES — A NEW RECORD". Retro space age aesthetic, muted blues and oranges, mission insignia style, halftone dots. Aspect ratio 3:4.

---

#### `manuscript` — Medieval Illuminated Manuscript

> A medieval illuminated manuscript page from "The Chronicle of {NAME}". Hand-lettered in gold leaf and rich pigments on aged vellum. An ornate decorated capital "D" contains a portrait of {NAME} as a monk-scribe. The main text (in faux Latin/Old English style) tells of {COMMITS} great deeds and {LINES_DELETED} lines of darkness banished. Illustrated marginalia shows tiny monks battling bugs with quills, a dragon of tech debt being slain, {PRS} scrolls being sealed. Decorative borders contain vine-work with stats woven in: {ACTIVE_DAYS} days of labor, {STREAK}-day vigil, {HOTFIXES} miracles performed. Rich blues, reds, and gold leaf on cream vellum. Authentic 13th-century manuscript style. Aspect ratio 3:4.

---

#### `tarot` — Major Arcana Tarot Card

> A major arcana tarot card titled "THE ENGINEER" numbered {RANK_ROMAN} (for rank #{RANK}). {NAME} as a mystical figure seated on a throne of cables and circuit boards. Right hand holds a flaming sword ({FIXES} fixes), left hand holds a glowing orb ({FEATURES} features built). Above: a halo of {COMMITS} spinning commit hashes. Behind: a tree of life made of git branches with trunk labeled "develop" and branches for each domain area. At feet: golden river of {LINES_ADDED} lines added flowing left, red river of {LINES_DELETED} lines deleted flowing right. Tech debt serpent subdued beneath throne. Ornate gold border with mystical programming symbols. Rich occult art, gold leaf, deep purple and midnight blue. Aspect ratio 3:4.

---

#### `stained` — Gothic Cathedral Stained Glass

> A massive gothic cathedral stained glass window depicting the legend of {NAME}. Multi-panel narrative: Bottom panels show {NAME} as a young monk discovering scrolls of code. Middle panels show {NAME} in full armor battling a multi-headed dragon of code evils, sword inscribed "{LINES_DELETED} LINES PURGED". Upper panels show {NAME} ascending, building a grand cathedral of the codebase. Rose window at top contains {COMMITS} golden stars. Rich jewel tones — deep blues, rubies, emeralds — with golden leading between glass. Light streaming through casting colored shadows. Cathedral architecture framing. Aspect ratio 3:4.

---

#### `pinball` — Vintage Pinball Machine

> A vintage 1970s pinball machine viewed from above. The machine is called "CODE WIZARD" in chrome retro lettering. Playfield is circuit-board green with chrome rails. Bumpers labeled with top domain areas. Score display: "{COMMITS} COMMITS — {LINES_ADDED} LINES". Flippers labeled "FIX" and "BUILD". Day-of-week lanes with {BEST_DAY_NAME} lane lit brightest. "MULTIBALL" indicator: "{HOTTEST_MONTH_COMMITS} COMMITS — {HOTTEST_MONTH}". Backglass art shows a retro developer character. Photorealistic arcade rendering, dramatic lighting. Aspect ratio 3:4.

---

#### `cyberpunk` — Cyberpunk Neon Dashboard

> A cyberpunk neon data visualization dashboard floating in a rain-soaked cityscape. Holographic displays in neon pink, cyan, and purple. Center: bar chart of monthly commits with {HOTTEST_MONTH} spiking to {HOTTEST_MONTH_COMMITS}. Left: radial clock with {PEAK_HOURS} zone blazing orange. Right: pie chart of domain areas. Bottom ticker: "{COMMITS} COMMITS | {LINES_ADDED} LINES ADDED | {LINES_DELETED} LINES DELETED | {ACTIVE_DAYS} ACTIVE DAYS | RANK #{RANK}". Rain reflects neon on wet streets. Flying cars. Blade Runner aesthetic. Aspect ratio 16:9.

---

#### `anime` — Anime Battle Scene

> An epic anime battle scene. {NAME} as a cyber-armored warrior standing on a mountain of destroyed bugs and broken legacy code, wielding a glowing katana. Slash mark glows with "{LINES_DELETED} LINES PURGED". {COMMITS} spirit orbs float in the sky. Fallen monsters: merge conflicts hydra, tech debt golem, bug swarm. Power gauge shows "RANK #{RANK}". Dramatic sunset, speed lines, cel shading, cherry blossoms mixed with code fragments. Aspect ratio 16:9.

---

#### `renaissance` — Renaissance Oil Painting

> A grand Renaissance oil painting in Sistine Chapel style. "The Creation of the Codebase". {NAME} as a god-like figure reaching out, fingertips streaming golden code that builds a magnificent city below — towers of components, bridges of CI/CD pipelines, a cathedral labeled with the main domain area. Angels carry scrolls with stats: "{COMMITS} Commits", "{LINES_ADDED} Lines Forged", "{LINES_DELETED} Lines Purified". Below, tiny figures flee crumbling legacy code structures. Classical oil painting, rich chiaroscuro, ornate gold frame. Aspect ratio 16:9.

---

### Step 6: Present Results

After generating images:
1. Show each image to the user with a short description of the style and key stats featured
2. Note the file paths in `~/nano-banana-output/`
3. Offer to regenerate with tweaks, try different styles, or adjust the time range
