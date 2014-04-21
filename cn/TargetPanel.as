package cn 
{
	
	import flash.display.MovieClip;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import org.osflash.signals.Signal;
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	import flash.events.Event;
	
	
	public class TargetPanel extends MovieClip 
	{
		
		public var onBack:Signal;
		private var _target:int;
		private var interval:*;
		private var _w:int;
		public function TargetPanel() 
		{
			addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
		}
		
		private function onAddToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAddToStage);
			
			onBack=new Signal();
			_target=1;
			_w=stage.stageWidth;
			targetHolder.y=stage.stageHeight/2;
			for(var i:int=1;i<6;i++)
			{
				var target:MovieClip=targetHolder.getChildByName('t'+i) as MovieClip;
				target.x=_w*(i-1)+(_w-target.width)/2;
			}
			pushBtn.x=_w/2;
			pushBtn.y=stage.stageHeight-50;
			
			leftLight.height=rightLight.height=stage.stageHeight;
			rightLight.x=_w;
		}
		
		public function onUpdata(info:Object):void
		{
			
			if(info=='LEFT')
			{
				if(targetHolder.x>-4*_w)
				{
					TweenLite.to(targetHolder,0.5,{x:targetHolder.x-_w});
					_target++;
				}else
				{
					rightLight.gotoAndPlay(2);
				}
			}else if(info=='RIGHT')
			{
				if(targetHolder.x<0)
				{
					TweenLite.to(targetHolder,0.5,{x:targetHolder.x+_w});
					_target--;
				}else
				{
					leftLight.gotoAndPlay(2);
				}
			}else if(info=='DOWN')
			{
				pushBtn.play();
				GlobalData.target=_target;
				onBack.dispatch();
				//interval=setInterval(function d():void{clearInterval(interval);onBack.dispatch();trace(222)},500);
			}
		}
	}
}
