package cn
{
	import com.leapmotion.leap.Controller;
	import com.leapmotion.leap.events.LeapEvent;
	import org.osflash.signals.Signal;
	import com.leapmotion.leap.Tool;
	import com.leapmotion.leap.util.LeapUtil;
	import com.leapmotion.leap.Gesture;
	import flash.utils.getTimer;
	import com.leapmotion.leap.SwipeGesture;
	import com.leapmotion.leap.KeyTapGesture;

	public class LeapControl extends Controller
	{
		public var onFrame:Signal;
		public var onGesture:Signal;
		private var lastSwipe:int;
		
		public function LeapControl() 
		{
			super();
			onFrame=new Signal();
			onGesture=new Signal();
			
			this.addEventListener(LeapEvent.LEAPMOTION_CONNECTED,onConnectedHandler);
			this.addEventListener(LeapEvent.LEAPMOTION_FRAME,onFrameHandler);
		}
		
		private function onConnectedHandler(e:LeapEvent):void
		{
			trace('connected');
			this.enableGesture(Gesture.TYPE_SWIPE );
			this.enableGesture(Gesture.TYPE_KEY_TAP );
		}
		
		private function onFrameHandler(e:LeapEvent):void
		{
			onFrame.dispatch(e.frame);
			
			var now:int = getTimer();
			if ( now - lastSwipe >1000 )
			{
				var gestures:Vector.<Gesture> = e.frame.gestures();
				for each( var gesture:Gesture in gestures )
				{
					if ( gesture is SwipeGesture && gesture.state == Gesture.STATE_STOP )
					{
						var swipe:SwipeGesture = gesture as SwipeGesture;
						if ( Math.abs( swipe.direction.x ) > Math.abs( swipe.direction.y ) )
						{
							if ( swipe.direction.x > 0 )
							{ 
								onGesture.dispatch('RIGHT');							
							}
							else
							{
								onGesture.dispatch('LEFT');
							}
							lastSwipe = now;
							break;
						}
					}else if(gesture is KeyTapGesture && gesture.state == Gesture.STATE_STOP)
					{
						onGesture.dispatch('DOWN');
					}
				}
			}

			/*if(e.frame.tools.length>0)
			{
				var tool:Tool=e.frame.tools[0];
				onFrame.dispatch({'pos':[tool.tipPosition.x,tool.tipPosition.y,tool.tipPosition.z,tool.direction.pitch*LeapUtil.RAD_TO_DEG,tool.direction.yaw*LeapUtil.RAD_TO_DEG,tool.direction.roll*LeapUtil.RAD_TO_DEG]});
			}*/
		}
	}
}
