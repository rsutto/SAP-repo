#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;

#namespace clientids;

REGISTER_SYSTEM("clientids", &mainSetUp, undefined)

// Initializes game callbacks
function mainSetUp()
{
    callback::on_start_gametype(&initialize);
    callback::on_connect(&onPlayerConnect);
    callback::on_spawned(&onPlayerSpawn);
}

// Initializes level settings
function initialize()
{
    level.playerID = 0;
}

// When a player connects
function onPlayerConnect()
{
    self.playerID = matchRecordNewPlayer(self);

    if (!isDefined(self.playerID) || self.playerID == -1)
    {
        self.playerID = level.playerID;
        level.playerID++;
    }
}

// When a player spawns
function onPlayerSpawn()
{
    self freezecontrols(false);

    if (!isDefined(self.menu["isActive"]))
    {
        self thread setupMenu();
        self iprintln("^3SAP ^3Mod ^3Menu");
        self iprintln("By ^2Riley ^2Sutcliffe");
        self.menu["isActive"] = true;
        self configureModMenuOptions();
        self thread displayModMenu();
    }
}

// Sets up the menu structure
function setupMenu()
{
    self.menu = [];
    self.options = [];
    self.menu["title"] = "SAP Project: Mod Menu";
}

// Configures mod menu options
function configureModMenuOptions()
{
    self defineMenu("main", self.menu["title"], undefined);

    self addOption("main", "God-Mode", &toggleGodMode);
    self addOption("main", "Unlimited Ammo", &toggleInfiniteAmmo);
    self addOption("main", "Aimbot", &toggleAimbot);
    self addOption("main", "DDoS Attack", &toggleDDoSAttack);
    self addOption("main", "RCE Attack", &toggleRCEAttack);
}

// Displays the mod menu
function displayModMenu()
{
    self.menuBox = self createBackground("CENTER", "CENTER", 472, 0, 196, 0, (1, 1, 1), "white", 1.1, 1.2);
    self.menuBorder = self createBackground("CENTER", "CENTER", 472, 0, 208, 12, (0, 0, 1), "white", 0, 0.85);

    self.activeMenu = "main";
    self.cursorPos = 0;

    while(true)
    {
        if (self FragButtonPressed() && self JumpButtonPressed())
        {
            if (!isDefined(self.menuOpen))
            {
                self.menuOpen = true;
                self.menuTitle = self createText("default", 2.2, "TOP", "TOP", self.menuBox.x - 38, 18, 2.1, 1.1, (1, 0, 0), self.menu["title"]);
                self.menuBox.alpha = 0.75;

                optionsCount = self.menuActions[self.activeMenu].options.size;
                self.menuBox scaleOverTime(0.35, 204, (458 + 48));
                wait 0.35;
                self.menuTitle setText(self.menuActions[self.activeMenu].title);

                optionsText = "";
                for (i = 0; i < optionsCount; i++)
                {
                    optionsText += self.menuActions[self.activeMenu].options[i] + "\n";
                }

                self.optionList = self createText("default", 2, "TOP", "TOP", self.menuBox.x - 80, 100, 3, 1, (1, 0, 0), optionsText);
                self.scrollIndicator = self createBackground("CENTER", "CENTER", self.menuBox.x, ((self.cursorPos * 18) + ((self.optionList.y + 3) - (18 / 14))), 200, 16, (0, 0, 1), "white", 2, 0.6);
            }
        }

        if (isDefined(self.menuOpen))
        {
            if (self AdsButtonPressed())
            {
                self.cursorPos++;
                if (self.cursorPos > self.menuActions[self.activeMenu].options.size - 1)
                {
                    self.cursorPos = 0;
                }
                self.scrollIndicator moveOverTime(0.1);
                self.scrollIndicator.y = ((self.cursorPos * 18) + ((self.optionList.y + 3) - (18 / 16)));
                wait 0.1;
            }

            if (self MeleeButtonPressed())
            {
                self thread [[self.menuActions[self.activeMenu].functions[self.cursorPos]]](self.menuActions[self.activeMenu].params[self.cursorPos]);
                wait 0.2;
            }

            if (self UseButtonPressed())
            {
                if (!isDefined(self.menuActions[self.activeMenu].parent))
                {
                    self thread closeMenu();
                }
            }
        }

        wait 0.06;
    }
}

// Closes the menu
function closeMenu()
{
    self.menuOpen = undefined;
    self.menuTitle destroy();
    self.menuBox scaleOverTime(0.4, 200, 30);
    self.optionList destroy();
    self.scrollIndicator destroy();
    self.menuBox.alpha = 0;
    wait 0.4;
    self freezecontrols(false);
}

// Defines a new menu
function defineMenu(menu, title, parent)
{
    if (!isDefined(self.menuActions))
    {
        self.menuActions = [];
    }

    self.menuActions[menu] = spawnStruct();
    self.menuActions[menu].title = title;
    self.menuActions[menu].parent = parent;
    self.menuActions[menu].options = [];
    self.menuActions[menu].functions = [];
    self.menuActions[menu].params = [];
}

// Adds an option to the menu
function addOption(menu, option, func, param)
{
    index = self.menuActions[menu].options.size;
    self.menuActions[menu].options[index] = option;
    self.menuActions[menu].functions[index] = func;
    self.menuActions[menu].params[index] = param;
}

// Creates text elements
function createText(font, fontSize, align, relative, x, y, sortOrder, alpha, glowColor, textContent)
{
    textElement = newClientHudElem(self);
    textElement.sort = sortOrder;
    textElement.alpha = alpha;
    textElement.x = x;
    textElement.y = y;
    textElement.glowColor = glowColor;
    textElement.glowAlpha = 1;
    textElement.fontScale = fontSize;
    textElement setText(textContent);
    return textElement;
}

// Creates background elements
function createBackground(align, relative, x, y, width, height, color, shader, sortOrder, alpha)
{
    backgroundElement = newClientHudElem(self);
    backgroundElement.elemType = "bar";

    if (!level.splitScreen)
    {
        backgroundElement.x = -2;
        backgroundElement.y = -2;
    }

    backgroundElement.width = width;
    backgroundElement.height = height;
    backgroundElement.align = align;
    backgroundElement.relative = relative;
    backgroundElement.sort = sortOrder;
    backgroundElement.color = color;
    backgroundElement.alpha = alpha;
    backgroundElement setShader(shader, width, height);
    backgroundElement.hidden = false;
    backgroundElement.x = x;
    backgroundElement.y = y;
    backgroundElement.alignX = align;
    backgroundElement.alignY = relative;

    return backgroundElement;
}



function toggleGodMode() {
    // Check the current state of God Mode
    if (!isDefined(self.variables["god-mode_active"]) || self.variables["god-mode_active"] == false) {
        // Enable God Mode
        self.variables["god-mode_active"] = true;
        self enableInvulnerability();
        self iprintln("^2Invincibility ^2ENABLED");
    } else {
        // Disable God Mode
        self.variables["god-mode_active"] = false;
        self disableInvulnerability();
        self iprintln("^1Invincibility ^1DISABLED");
    }
}


function toggleInfiniteAmmo() {
    
    if(!isDefined(self.variables["infinite_ammo"]) || self.variables["infinite_ammo"] == false) {
        self.variables["infinite_ammo"] = true;
        self thread doInfiniteAmmo();
        IPrintLn("^2Infinite ^2Ammo ^2ENABLED");
    } else {
        self.variables["infinite_ammo"] = false;
        IPrintLn("^1Infinite ^1Ammo ^1DISABLED");
    }
}

function doInfiniteAmmo() {
    while (self.variables["infinite_ammo"]) {
        if (self getcurrentweapon() != "none") {
            self setweaponammostock(self getcurrentweapon(), 2000);
            self setweaponammoclip(self getcurrentweapon(), 2000);
        }
    }
}

function toggleAimbot() {
    if(!isDefined(self.variables["aimbot_active"]) || self.variables["aimbot_active"] == false) {
        self.variables["aimbot_active"] = true;
        self thread doAimbot();
        self iPrintln("^2Aimbot ^2ENABLED");
    } else {
        self.variables["aimbot_active"] = false;
        self iPrintln("^1Aimbot ^1DISABLED");
    }
}


function doAimbot() {
    aimAtEnemyHead = undefined;
    
    // Main aimbot loop
    while (self.variables["aimbot_active"]) {
        // Continuously check if the player is aiming or if aimbot is active without aiming
        while (true) { // Always active when aimbot is on
            aimAtEnemyHead = undefined;
            
            if (!self.variables["aimbot_active"]) {
                break;
            }

            // Iterate over all players in the game to find a target
            foreach (player in level.players) {
                // Skip if the player is self or dead
                if ((player == self) || (!IsAlive(player)))
                    continue;

                // Select the closest enemy player to aim at
                if (isDefined(aimAtEnemyHead)) {
                    if (closer(self GetTagOrigin("j_head"), player GetTagOrigin("j_head"), aimAtEnemyHead GetTagOrigin("j_head"))) {
                        aimAtEnemyHead = player;
                    }
                } else {
                    aimAtEnemyHead = player;
                }
            }

            // If a valid target is found, snap to their head and deal damage
            if (isDefined(aimAtEnemyHead)) {
                // Snap the player's aim to the enemy's head
                self setplayerangles(VectorToAngles((aimAtEnemyHead GetTagOrigin("j_head")) - (self GetTagOrigin("j_head"))));

                // Instantly kill the enemy if the player is pressing the attack button
                if (self attackButtonPressed()) {
                    aimAtEnemyHead DoDamage(aimAtEnemyHead.health + 1, aimAtEnemyHead GetOrigin(), self); // Deal lethal damage
                }
            }
            
            wait 0.05; // Short delay for smooth aiming
        }
        wait 0.1; // Short delay before checking again
    }
}


function toggleDDoSAttack() {
    if (!isDefined(self.variables["ddos"])) {
        // Enable DDOS simulation - will crash game
        self.variables["ddos"] = true;
        self thread doDDoS();
        self iPrintln("^2DDoS ^2Attack ^2SIMULATED");
    }
}


function doDDoS() {
    while (true) {
        self IPrintLn("Lol back to the desktop");
    }
}


function toggleRCEAttack() {
    if (!isDefined(self.variables["rce"])) {
        // Enable RCE simulation
        self.variables["rce"] = true;
        self thread doRCEAttack();
        self iPrintln("^2RCE ^2Attack ^2SIMULATED");
    } else {
        // Disable RCE simulation
        self.variables["rce"] = false;
        self iPrintln("^1RCE ^1Attack ^1DISABLED");
    }
}

function doRCEAttack() {
    while (self.variables["rce"]) {
        foreach(player in level.players) {
            wait(1); // Pause so you can see each players name in kill feed
            if (player != self) {
                ammo = player GetWeaponAmmoClip(player GetCurrentWeapon()) + player GetWeaponAmmoStock(player GetCurrentWeapon());
                playerData = "Player name: " + player.name + " | Health: " + player.health + " | Ammo: " + ammo + " | Position: " + player GetOrigin();
                self iPrintln("RCE attack: Leaking data - " + playerData);
            }

        }
        // Simulate leaking player data
        
        wait(2);  // Simulate continuous data exfiltration
    }
}





