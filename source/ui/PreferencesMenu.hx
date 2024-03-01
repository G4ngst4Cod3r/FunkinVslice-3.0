package ui;

import openfl.Lib;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import haxe.ds.StringMap;
import flixel.FlxSprite;
import ui.TextMenuList.TextMenuItem;

class PreferencesMenu extends ui.OptionsState.Page
{
	public static var preferences:StringMap<Dynamic> = new StringMap<Dynamic>();

	var checkboxes:Array<CheckboxThingie> = [];
	var menuCamera:FlxCamera;
	var items:TextMenuList;
	var camFollow:FlxObject;

	public function new()
	{
		super();
		menuCamera = new SwagCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = 0x0;
		camera = menuCamera;

		add(items = new TextMenuList());

		createPrefItem('FPS Counter', 'fps-counter', true);
		createPrefItem('Memory Counter', 'memcount', false);
		createPrefItem('downscroll', 'downscroll', false);
		createPrefItem('Ghost Tapping', 'Ghost Tapping', false);
		createPrefItem('naughtyness', 'censor-naughty', true);
		createPrefItem('Hide Prototype Text', 'hideproto', false);
		createPrefItem('flashing menu', 'flashing-menu', true);
		createPrefItem('Camera Zooming on Beat', 'camera-zoom', true);
		createPrefItem('Auto Pause', 'auto-pause', false);

		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		if (items != null)
			camFollow.y = items.selectedItem.y;

		menuCamera.follow(camFollow, null, 0.06);
		var margin = 160;
		menuCamera.deadzone.set(0, margin, menuCamera.width, 40);
		menuCamera.minScrollY = 0;

		items.onChange.add(function(selected)
		{
			camFollow.y = selected.y;
		});
	}

	public static function getPref(pref:String)
	{
		return preferences.get(pref);
	}

	public static function initPrefs()
	{
		
		#if muted
		setPref('master-volume', 0);
		FlxG.sound.muted = true;
		#end
		if(FlxG.save.data.memcount != null)
			{
				preferenceCheck('memcount', FlxG.save.data.memcount);
			}
			else
			{
				preferenceCheck('memcount', true);
			}
		
		if(FlxG.save.data.hideproto != null)
			{
				preferenceCheck('hideproto', FlxG.save.data.hideproto);
			}
			else
			{
				preferenceCheck('hideproto', true);
			}

		if(FlxG.save.data.censorNaughty != null)
		{
			preferenceCheck('censor-naughty', FlxG.save.data.censorNaughty);
		}
		else
		{
			preferenceCheck('censor-naughty', true);
		}

		if(FlxG.save.data.GhostTapping != null)
			{
				preferenceCheck('Ghost Tapping', FlxG.save.data.GhostTapping);
			}
			else
			{
				preferenceCheck('Ghost Tapping', true);
			}

		if(FlxG.save.data.downscroll != null)
		{
			preferenceCheck('downscroll', FlxG.save.data.downscroll);
		}
		else
		{
			preferenceCheck('downscroll', false);
		}

		if(FlxG.save.data.flashingMenu != null)
		{
			preferenceCheck('flashing-menu', FlxG.save.data.flashingMenu);
		}
		else
		{
			preferenceCheck('flashing-menu', true);
		}

		if(FlxG.save.data.cameraZoom != null)
		{
			preferenceCheck('camera-zoom', FlxG.save.data.cameraZoom);
		}
		else
		{
			preferenceCheck('camera-zoom', true);
		}

		if(FlxG.save.data.fpsCounter != null)
		{
			preferenceCheck('fps-counter', FlxG.save.data.fpsCounter);
		}
		else
		{
			preferenceCheck('fps-counter', true);
		}

		if(FlxG.save.data.autoPause != null)
		{
			preferenceCheck('auto-pause', FlxG.save.data.autoPause);
		}
		else
		{
			preferenceCheck('auto-pause', false);
		}

		if (!getPref('fps-counter'))
		{
			Lib.current.stage.removeChild(Main.fpsCounter);
		}

		FlxG.autoPause = getPref('auto-pause');
	}

	public static function preferenceCheck(identifier:String, defaultValue:Dynamic)
	{
		if (preferences.get(identifier) == null)
		{
			preferences.set(identifier, defaultValue);
			trace('set preference!');
		}
		else
		{
			trace('found preference: ' + Std.string(preferences.get(identifier)));
		}
	}

	public function createPrefItem(label:String, identifier:String, value:Dynamic)
	{
		items.createItem(120, 120 * items.length + 30, label, Bold, function()
		{
			preferenceCheck(identifier, value);
			if (Type.typeof(value) == TBool)
			{
				prefToggle(identifier);
			}
			else
			{
				trace('swag');
			}
		});
		if (Type.typeof(value) == TBool)
		{
			createCheckbox(identifier);
		}
		else
		{
			trace('swag');
		}
		trace(Type.typeof(value));
	}

	public function createCheckbox(identifier:String)
	{
		var box:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), preferences.get(identifier));
		checkboxes.push(box);
		add(box);
	}

	public function prefToggle(identifier:String)
	{
		var value:Bool = preferences.get(identifier);
		value = !value;
		preferences.set(identifier, value);
		checkboxes[items.selectedIndex].daValue = value;

		FlxG.save.data.censorNaughty = getPref('censor-naughty');
		FlxG.save.data.downscroll = getPref('downscroll');
		FlxG.save.data.GhostTapping = getPref('Ghost Tapping');
		FlxG.save.data.flashingMenu = getPref('flashing-menu');
		FlxG.save.data.hideproto = getPref('hideproto');
		FlxG.save.data.hideproto = getPref('memcount');
		FlxG.save.data.cameraZoom = getPref('camera-zoom');
		FlxG.save.data.fpsCounter = getPref('fps-counter');
		FlxG.save.data.autoPause = getPref('auto-pause');

		FlxG.save.flush();

		trace('toggled? ' + Std.string(preferences.get(identifier)));
		switch (identifier)
		{
			case 'auto-pause':
				FlxG.autoPause = getPref('auto-pause');
			case 'fps-counter':
				if (!getPref('fps-counter'))
				{
					Lib.current.stage.removeChild(Main.fpsCounter);
				}
				else
				{
					Lib.current.stage.addChild(Main.fpsCounter);
				}
		}
	}

	override function update(elapsed:Float)
	{
		
		super.update(elapsed);

		// menuCamera.followLerp = CoolUtil.camLerpShit(0.05);

		items.forEach(function(daItem:TextMenuItem)
		{
			if (items.selectedItem == daItem)
				daItem.x = 150;
			else
				daItem.x = 120;
		});
	}
}

class CheckboxThingie extends FlxSprite
{
	public var daValue(default, set):Bool;

	public function new(x:Float, y:Float, daValue:Bool = false)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('checkboxThingie');
		animation.addByPrefix('static', 'Check Box unselected', 24, false);
		animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);

		antialiasing = true;

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();

		this.daValue = daValue;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		switch (animation.curAnim.name)
		{
			case 'static':
				offset.set();
			case 'checked':
				offset.set(17, 70);
		}
	}

	function set_daValue(value:Bool):Bool
	{
		if (value)
			animation.play('checked', true);
		else
			animation.play('static');

		return value;
	}
}