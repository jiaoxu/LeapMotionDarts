package cn 
{
	
	import flash.display.MovieClip;
	import com.leapmotion.leap.Frame;
	import flash.filters.GlowFilter;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	import org.osflash.signals.Signal;
	import com.leapmotion.leap.Pointable;
	import flash.events.Event;
	
	
	public class CounterPanel extends MovieClip
	{
		public var onBack:Signal;
		private var _length:int;
		private var oldFinger:MovieClip;
		private var glowFilter:GlowFilter;
		private var fingerPoint:FingerPoint;
		private var fingers:Array;
		private var numPoint:int = 5;
		
		public function CounterPanel() 
		{
			addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
		}
		
		private function onAddToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAddToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,distroy);
			counterMc.x=stage.stageWidth-counterMc.width-100;
			
			onBack=new Signal();
			glowFilter=new GlowFilter(0x00ffff,0.5,20,20,2);
			
			
			fingers=new Array();
			for(var i:int=0;i<numPoint;i++)
			{
				fingerPoint=new FingerPoint();
				addChild(fingerPoint);
				fingers.push(fingerPoint);
				fingerPoint.visible=false;
			}
		}
		
		public function onUpdata(frame:Frame):void
		{
			_length=frame.fingers.length;
			var finger:MovieClip
			
			for(var i:int=1;i<6;i++)
			{    
				finger=counterMc.getChildByName('finger'+i) as MovieClip;
				if(i==_length)
				{
					finger.nextFrame();
					finger.filters=[glowFilter];
					TweenLite.to(finger,0.3,{scaleX:1.2,scaleY:1.2,easin:Back.easeOut});
					if(finger.currentFrame==160)
					{
						GlobalData.counter=_length;
						onBack.dispatch();
					}
					
					
				}else if(finger.currentFrame!=0)
				{
					finger.prevFrame();
					finger.filters=[];
					TweenLite.to(finger,0.3,{scaleX:1,scaleY:1});
				}
				
				var point:FingerPoint=fingers[i-1];  
				if((i-1)<frame.pointables.length)
				{
					var pointable:Pointable = frame.pointables[i-1];
					point.x=(pointable.tipPosition.x)*2+600;
					point.y=(-pointable.tipPosition.y*2+600);
					point.z=(-pointable.tipPosition.z)*2;
					point.visible=true;
				}else
				{
					point.visible=false
				}
				
			}
		}
		
		private function distroy(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE,distroy);
			onBack=null;
		}
	}
}
