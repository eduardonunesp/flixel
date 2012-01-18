package org.flixel.system.input
{
	/**
	 * Basic input class that manages the fast-access Booleans and detailed key-state tracking.
	 * Keyboard extends this with actual specific key data.
	 * 
	 * @author Adam Atomic
	 */
	public class Input
	{
        // Values of "key.pressedFrame" (for reference)
        //   0 - Not pressed (ever)
        //   A positive value - The frame the key was last pressed down on
        //      (and which implies that the key is currently being held down)
        //   A negative value - The frame the key was last released on
            
		/**
		 * @private
		 */
		internal var _lookup:Object;
		/**
		 * @private
		 */
		internal var _map:Vector.<Key>;
		/**
		 * @private
		 */
		internal var _totalKeys:uint = 256;

       /**
        * @private
        */
       //Start at 1, because "0" means "never pressed"
       internal var _currentFrame:int = 1;
		
		/**
		 * Constructor
		 */
        public function Input(totalKeys:uint = 256)
        {   
            _totalKeys = totalKeys;
			_lookup = new Object();
			_map = new Vector.<Key>(_totalKeys);
		}
		
        /*
        * Updates the current frame number
        */
		public function update():void
		{
            _currentFrame++;
		}
		
		/**
		 * Resets all the keys.
		 */
		public function reset():void
		{
			var i:uint = 0;
			while(i < _totalKeys)
			{
				var key:Key = _map[i++];
				if(key == null) continue;
				this[key.name] = false;
				key.framePressed = 0;
			}
		}
		
		/**
		 * Check to see if this key is pressed.
		 * 
		 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
		 * 
		 * @return	Whether the key is pressed
		 */
		//What if a key with that name is not found? :(
		public function pressed(KeyName:String):Boolean { return this[KeyName]; }
		
		/**
		 * Check to see if this key was just pressed.
		 * 
		 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
		 * 
		 * @return	Whether the key was just pressed
		 */
		public function justPressed(KeyName:String):Boolean { return _map[_lookup[KeyName]].framePressed == (_currentFrame); }
		
		/**
		 * Check to see if this key is just released.
		 * 
		 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
		 * 
		 * @return	Whether the key is just released.
		 */
		public function justReleased(KeyName:String):Boolean { return _map[_lookup[KeyName]].framePressed == (-_currentFrame); }
		
		/**
		 * Get how many frames (or ticks) have passed since the key was last pressed.
		 * 
		 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
		 * 
		 * @return	The number of frames since it was pressed. Will return 0 if the key was just pressed, and return -1 if the key has been released.
		 */
		public function framesSincePress(KeyName:String):int 
		{ 
			var key:Key = _map[_lookup[KeyName]];
			return (key.framePressed <= 0) ? -1 : (_currentFrame - key.framePressed) ;
		}
		
		/**
		 * Get how many frames (or ticks) have passed since the key was last released.
		 * 
		 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
		 * 
		 * @return	The number of frames since it was released. Will return 0 if the key was just released, and return -1 if the key is currently pressed or has not yet been released.
		 */
		public function framesSinceRelease(KeyName:String):int 
		{
			var key:Key = _map[_lookup[KeyName]];
			return (key.framePressed >= 0) ? -1 : (_currentFrame + key.framePressed);
		}
		
		
		
		/**
		 * If any keys are not "released" (0),
		 * this function will return an array indicating
		 * which keys are pressed and what state they are in.
		 * 
		 * @return	An array of key state data.  Null if there is no data.
		 */
		public function record():Array
		{
			var data:Array = new Array();
			var i:uint = 0;
			while(i < _totalKeys)
			{
				var key:Key = _map[i++];
				if((key == null) || (key.framePressed == 0))
					continue;
				
				data.push({code:i-1,value:key.framePressed});
			}
			
			return (data.length > 0) ? data : null;
		}
		
		/**
		 * Part of the keystroke recording system.
		 * Takes data about key presses and sets it into array.
		 * 
		 * @param	Record	Array of data about key states.
		 */
		public function playback(Record:Array):void
		{
			var i:uint = 0;
			var l:uint = Record.length;
			while(i < l)
			{
				var o:Object = Record[i++];
				var key:Key = _map[o.code];
				key.framePressed = o.value;
				if(o.value > 0)
					this[key.name] = true;
			}
		}
		
		/**
		 * Look up the key code for any given string name of the key or button.
		 * 
		 * @param	KeyName		The <code>String</code> name of the key.
		 * 
		 * @return	The key code for that key.
		 */
		public function getKeyCode(KeyName:String):int
		{
			return _lookup[KeyName];
		}

     
        /** 
         * Look up the key's name for a given key code. Useful for "change controls" menus.
         * 
         * @param   KeyCode     The KeyCode for the key.
         * 
         * @return  The name of that key.
         */
        public function getKeyName(KeyCode:uint):String
        {   
            var key:Key = _map[KeyCode];
            return (key) ? key.name : "[key #" + KeyCode + "]";
        }   
		
		/**
		 * Check to see if any keys are pressed right now.
		 * 
		 * @return	Whether any keys are currently pressed.
		 */
		public function any():Boolean
		{
			var i:uint = 0;
			while(i < _totalKeys)
			{
				var key:Key = _map[i++];
				if(key && (key.framePressed > 0))
					{ return true; }
			}
			
			return false;
		}

        /**
         * Check to see if any keys were just pressed.
         * 
         * @return  Whether any keys were just pressed.
         */
        public function justPressedAny():Boolean
        {
            var targetFrame:int = _currentFrame;
            var i:uint = 0;
            while(i < _totalKeys)
            {
                var key:Key = _map[i++];
                if(key && (key.framePressed == targetFrame))
                    { return true; }
            }

            return false;
        }

        /**
         * Check to see if any keys were just released.
         * 
         * @return  Whether any keys were just released.
         */
        public function justReleasedAny():Boolean
        {
            var targetFrame:int = -_currentFrame;
            var i:uint = 0;
            while(i < _totalKeys)
            {
                var key:Key = _map[i++];
                if(key && (key.framePressed == targetFrame))
                    { return true; }
            }

            return false;
        }

		/**
		 * An internal helper function used to build the key array.
		 * 
		 * @param	KeyName		String name of the key (e.g. "LEFT" or "A")
		 * @param	KeyCode		The numeric Flash code for this key.
		 */
		protected function addKey(KeyName:String,KeyCode:uint):void
		{
			_lookup[KeyName] = KeyCode;
			_map[KeyCode] = new Key(KeyName, KeyCode);
		}
		
		//Not actually more efficient, but definitely more organized
		protected function setKeyPress(KeyCode:uint):void
		{
			var key:Key = _map[KeyCode];
			if(key == null) return;
			
			key.framePressed = _currentFrame;
			this[key.name] = true;
		}
		
		//Not actually more efficient, but definitely more organized
		protected function setKeyRelease(KeyCode:uint):void
		{
			var key:Key = _map[KeyCode];
			if(key == null) return;
			
			key.framePressed = -_currentFrame;
			this[key.name] = false;
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			_lookup = null;
			_map = null;
		}
	}
}

//Should this be a public class instead?
// It won't be used outside of here anyway. :/
final class Key
{
	public function Key(name:String, keyCode:uint)
	{
		this.name = name;
		this.keyCode = keyCode;
	}
	
	public var name:String;
	public var keyCode:uint;
	
	public var framePressed:int = 0;
}
