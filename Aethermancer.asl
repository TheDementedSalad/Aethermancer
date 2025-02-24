//Aethermancer Demo Autosplitter V1.0 15/02/2025
//Timed via Load Remover - Please compare to Game Time
//Credit to:
//TheDementedSalad - Created the splitter
//Joey - Testing

state("Aethermancer")
{}

startup
{
	timer.CurrentTimingMethod = TimingMethod.GameTime;
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "Aethermancer";
	vars.Helper.Settings.CreateFromXml("Components/Aethermancer.Settings.xml");
	vars.Helper.LoadSceneManager = true;
	
	vars.completedSplits = new HashSet<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => {
		vars.Helper["currentState"] = mono.Make<byte>("GameController", "Instance", "GameState", "CurrentState");
		vars.Helper["Area"] = mono.Make<byte>("ExplorationController", "Instance", "CurrentArea");
		vars.Helper["Bubble"] = mono.Make<byte>("ExplorationController", "Instance", "CurrentBubble");
		vars.Helper["IntroSkip"] = mono.Make<bool>("TutorialIntroScript", "Instance", "IntroCutscene", "IntroHasBeenSkipped");
		vars.Helper["isPaused"] = mono.Make<bool>("GameController", "Instance", "TimeScaleManager", "isPaused");
		vars.Helper["useLoadScreen"] = mono.Make<byte>("GameController", "Instance", "SceneLoader", "useLoadingScreen");
		
		vars.Helper["enemyType"] = mono.Make<byte>("CombatController", "Instance", "CurrentEncounter", "EncounterType");
		vars.Helper["combatState"] = mono.Make<byte>("CombatController", "Instance", "State", "State", "CurrentState", 0x40); 
		
		//vars.Helper["LeftTalk"] = mono.Make<bool>("UIController", "Instance", "DialogueDisplay", "LeftCharacterDisplay", "isTalking");
		//vars.Helper["RightTalk"] = mono.Make<bool>("UIController", "Instance", "DialogueDisplay", "RightCharacterDisplay", "isTalking");
		//vars.Helper["RightTalkNorm"] = mono.Make<bool>("UIController", "Instance", "DialogueDisplay", "RightCharacterDisplay", "isNormalDialogue");
		
		/*
		vars.Helper["FinishedEncounters"] = mono.Make<byte>("GameController", "Instance", "GameState", "FinishedEncounterCount");
		vars.Helper["enemyType"] = mono.Make<byte>("CombatController", "Instance", "CurrentEncounter", "EncounterType");
		vars.Helper["Defeated"] = mono.Make<bool>("ExplorationController", "Instance", "lastMonsterGroup", "EncounterDefeated");
		vars.Helper["Combats"] = mono.Make<byte>("ExplorationController", "Instance", "TotalCombatsFoughtThisRun");
		vars.Helper["CombatData"] = mono.Make<byte>("GameController", "Instance", "SceneLoader", "CurrentSceneType");
		vars.Helper["CombatData2"] = mono.Make<byte>("GameController", "Instance", "SceneLoader", "transitionType");
		*/
		
        return true;
    });
}

onStart
{
	vars.completedSplits.Clear();
}
start
{
	return current.Area == 0 && old.Area == 4 && current.Bubble == 255 || current.Area == 4 && current.Bubble == 255 && current.IntroSkip && !old.IntroSkip && !current.isPaused;
}

update
{
	current.activeScene = vars.Helper.Scenes.Active.Name == null ? current.activeScene : vars.Helper.Scenes.Active.Name;			//creates a function that tracks the games active Scene name

    //if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");			//Prints when a new scene becomes active
}

split
{
	string setting = "";
	
	if(current.Bubble != old.Bubble || current.Area != old.Area){
		setting = "Level_" + current.Area + "_" + current.Bubble;
	}

	if(current.Area == 2 && current.Bubble == 3 && current.combatState == 5 && old.combatState != 5 && current.enemyType == 2)
	{
		return true;
	}
	
	// Debug. Comment out before release.
	if (!string.IsNullOrEmpty(setting))
	vars.Log(setting);
		
	if (settings.ContainsKey(setting) && settings[setting] && vars.completedSplits.Add(setting)){
		return true;
	}
}

isLoading
{
	return current.currentState == 1 || current.currentState == 3 || current.isPaused && current.currentState == 2 || current.activeScene == "MainMenuScene"
}

reset
{
	return current.activeScene != "MainMenuScene" && old.activeScene == "MainMenuScene";
}
