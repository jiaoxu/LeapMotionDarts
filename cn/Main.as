package cn 
{
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Circ;
	
	public class Main extends MovieClip 
	{
		private var leapControl:LeapControl;
		private var logoPanel:LogoPanel;
		private var counterPanel:CounterPanel;
		private var targetPanel:TargetPanel;
		private var gamePanel:GamePanel;
		
		public function Main() 
		{
			addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
		}
		
		private function onAddToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAddToStage);
			stage.align=StageAlign.TOP_LEFT;
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.displayState=StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			this.bg.visible=false;
			this.bg.width=stage.stageWidth;
			this.bg.height=stage.stageHeight;
			initLeapMotion();
			
			logoPanel=new LogoPanel();
			addChild(logoPanel);
			logoPanel.x=stage.stageWidth/2;
			logoPanel.y=stage.stageHeight/2;
			TweenLite.from(logoPanel,0.5,{scaleX:5,scaleY:5,alpha:0,ease:Circ.easeOut,onComplete:function t1():void
				{
					TweenLite.to(logoPanel,0.5,{delay:2,scaleX:0.3,scaleY:0.3,alpha:0,ease:Circ.easeIn,onComplete:function t2():void
						{
							initCountPanel();
						}});
				}});
		}
		
		private function initCountPanel():void
		{
			var c:*=this.getChildAt(1);
			this.removeChild(c);
			c=null;
			
			counterPanel=new CounterPanel();
			addChild(counterPanel);
			leapControl.onFrame.add(onFrameHandler);
			counterPanel.onBack.addOnce(counterPanelBackHandler);
			TweenLite.from(counterPanel,1,{alpha:0,ease:Circ.easeOut});
		}
		
		private function onFrameHandler(info:*):void
		{
			counterPanel.onUpdata(info);
		}
		
		private function counterPanelBackHandler():void
		{
			leapControl.onFrame.remove(onFrameHandler);
			removeChild(counterPanel);
			counterPanel=null;
			targetPanel=new TargetPanel();
			addChild(targetPanel);
			targetPanel.onBack.addOnce(targetBackHandler);
			TweenLite.from(targetPanel,1,{alpha:0,ease:Circ.easeOut});
			leapControl.onGesture.add(onGestureHandler);
			this.bg.visible=true;
			TweenLite.from(bg,0.5,{alpha:0,ease:Circ.easeOut});
		}
		
		private function onGestureHandler(info:Object):void
		{
			targetPanel.onUpdata(info);
		}
		
		private function targetBackHandler():void
		{
			gamePanel=new GamePanel();
			addChild(gamePanel);
			gamePanel.onBack.add(gameBackHandler);
			leapControl.onFrame.add(gameFrameHandler);
		}
		
		private function gameBackHandler(info:String):void
		{
			if(info=='INIT')
			{
				this.bg.visible=false;
				removeChild(targetPanel);
			}else if(info=='RESTART')
			{
				leapControl.onFrame.remove(gameFrameHandler);
				gamePanel.onBack.removeAll();
				initCountPanel();
			}
		}
		
		private function gameFrameHandler(info:*):void
		{
			gamePanel.onUpData(info);
		}
		
		private function initLeapMotion():void
		{
			leapControl=new LeapControl();
		}
	}
	
}
