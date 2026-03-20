# Firefox-Based Browsers Unified Config (Zen / LibreWolf / Firefox)

## 1. Configuration Architecture (What actually happens under the hood)

All three browsers—Firefox, LibreWolf, and Zen—share the same preference system:

**Load order (important):**

1. Built-in defaults
2. `autoconfig` (e.g., `librewolf.overrides.cfg`)
3. Profile `prefs.js` (runtime state)
4. `user.js` (**your override layer, applied at startup**)

👉 Key implication:

* `user.js` is **idempotent but not persistent** (it rewrites prefs on launch).
* `prefs.js` is **mutable runtime state** (UI changes go here).
* `.cfg` files are **strong enforcement (enterprise-style)**.

---

## 2. Recommended Strategy (Clean + Maintainable)

### Use layered configuration:

| Layer                      | Purpose                | Scope               |
| -------------------------- | ---------------------- | ------------------- |
| `user.js`                  | Cross-browser baseline | ✅ All               |
| `librewolf.overrides.cfg`  | Hard enforcement       | 🟡 LibreWolf only   |
| `userChrome.css`           | UI customization       | ✅ All               |
| `policies.json` (optional) | Enterprise controls    | ✅ Firefox/LibreWolf |

---

## 3. `user.js` (Portable Core)

This is your **single source of truth**.

### Minimal hardened baseline

```javascript
// === Privacy ===
pref("privacy.trackingprotection.enabled", true);
pref("privacy.trackingprotection.socialtracking.enabled", true);
pref("privacy.partition.network_state", true);

// === Fingerprinting resistance ===
pref("privacy.resistFingerprinting", true);

// === Web features ===
pref("dom.webnotifications.enabled", false);
pref("media.autoplay.default", 5);

// === Telemetry ===
pref("toolkit.telemetry.enabled", false);
pref("datareporting.healthreport.uploadEnabled", false);

// === Network ===
pref("network.dns.disablePrefetch", true);
pref("network.prefetch-next", false);

// === Cache ===
pref("browser.cache.disk.enable", false);
pref("browser.cache.memory.enable", true);
```

### Important nuance

* LibreWolf already enforces many of these → avoid redundant overrides unless you want consistency.
* Zen may expose experimental UI flags → keep those **out of shared config**.

---

## 4. Profile Locations (Reality vs Docs)

Paths differ more than most guides admit:

### Linux

* Firefox:
  `~/.mozilla/firefox/<profile>/`
* LibreWolf:
  `~/.librewolf/<profile>/` **or** `~/.config/librewolf/`
* Zen:

  * Native: `~/.zen/<profile>/`
  * Flatpak:
    `~/.var/app/app.zen_browser.zen/.zen/`

### Windows

* Firefox:
  `%APPDATA%\Mozilla\Firefox\Profiles\`
* LibreWolf:
  `%APPDATA%\librewolf\Profiles\`
* Zen:
  `%APPDATA%\Zen\`

👉 **Best practice:** Always confirm via:

```
about:profiles
```

---

## 5. LibreWolf Enforcement Layer (`librewolf.overrides.cfg`)

This is effectively **Firefox autoconfig**.

### When to use it

* Prevent UI/user overrides
* Lock down security-critical prefs

### Example

```javascript
// Must start with a comment line
pref("privacy.resistFingerprinting", true);
pref("network.cookie.cookieBehavior", 1);
```

### Gotchas

* Requires proper autoconfig loader (LibreWolf already ships it)
* Syntax errors silently break loading
* No dynamic evaluation (unlike `user.js` hacks)

---

## 6. UI Customization (`userChrome.css`)

### Enable first:

Go to:

```
about:config → toolkit.legacyUserProfileCustomizations.stylesheets = true
```

### Example

```css
/* Hide tabs bar */
#TabsToolbar {
  display: none !important;
}
```

### Use cases

* Vertical tabs (Zen-like)
* Minimal UI
* Custom layouts (e.g., potatofox)

👉 This is where Zen differs most—it already has opinionated UI, so reuse CSS selectively.

---

## 7. Migration Strategy (Correct + Safe)

### DO copy:

* `user.js`
* `userChrome.css`
* bookmarks (`places.sqlite`)
* extensions (optional)

### DO NOT copy:

* `compatibility.ini`
* `xulstore.json`
* `startupCache/`

### Reason:

These files contain **build-specific assumptions** → break cross-browser portability.

---

## 8. Advanced: Policy-Based Control (`policies.json`)

For reproducible setups (especially useful in labs or multi-machine configs):

```json
{
  "policies": {
    "DisableTelemetry": true,
    "BlockAboutConfig": false,
    "ExtensionSettings": {
      "*": {
        "installation_mode": "allowed"
      }
    }
  }
}
```

📍 Location:

```
<browser>/distribution/policies.json
```

---

## 9. Common Pitfalls (Important)

### 1. `user.js` "not working"

* Happens if profile path is wrong
* Or overwritten by sync/extensions

### 2. LibreWolf conflicts

* LibreWolf resets some prefs intentionally
* Don’t fight defaults unless necessary

### 3. Fingerprinting breakage

Enabling:

```javascript
privacy.resistFingerprinting = true
```

→ breaks:

* timezone detection
* some sites (e.g., captchas, DRM)

### 4. Cache disabling

```javascript
browser.cache.disk.enable = false
```

→ hurts performance significantly on low RAM systems

---

## 10. Recommended Repo Structure

```
firefox-config/
├── user.js
├── librewolf/
│   └── librewolf.overrides.cfg
├── chrome/
│   └── userChrome.css
├── policies/
│   └── policies.json
└── README.md
```

---

## 11. Key Insight (What most guides miss)

You’re not just “configuring browsers”—you’re defining:

> A **deterministic browser state machine** where:
>
> * `user.js` = declarative config
> * `prefs.js` = runtime diff
> * `.cfg` = enforcement layer

This mental model prevents 90% of debugging confusion.

---

If you want, I can:

* Convert this into a **clean README-ready document**
* Or build a **fully hardened `user.js` (Arkenfox-style but simplified)** tailored for your workflow (dev vs privacy vs performance)
