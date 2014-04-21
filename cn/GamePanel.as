package cn 
{
	import flash.display.MovieClip;
	import flash.net.dns.ARecord;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.Parsers;
	import away3d.events.LoaderEvent;
	import away3d.entities.Mesh;
	import away3d.primitives.SphereGeometry;
	import away3d.materials.ColorMaterial;
	import away3d.textures.BitmapTexture;
	import away3d.materials.TextureMaterial;
	
	import com.leapmotion.leap.Frame;
	import com.leapmotion.leap.util.LeapUtil;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import com.greensock.TimelineLite;
	
	import org.osflash.signals.Signal;
	import flash.events.KeyboardEvent;

	public class GamePanel extends MovieClip
	{
		
		[Embed(source="/dart.awd",mimeType="application/octet-stream")]
		public static var DartsModel:Class;
		
		[Embed(source="/Target.obj",mimeType="application/octet-stream")]
		public static var TargetModel:Class;
		
		private const M:Array=[Target1,Target2,Target3,Target4,Target5];
		
		public var onBack:Signal;
		private var view3d:View3D;
		private var isPlay:Boolean;
		
		private var targetLoader:Loader3D;
		private var targetContainer:ObjectContainer3D;
		private var dartsLoader:Loader3D;
		private var dartsAry:Array;
		private var aim:Mesh;
		private var aimAry:Array;
		private var oldZ:Number;
		private var currentCounter:int;
		private var posAry:Array;
		private var rp:ResultPoint;
		private var distanceAry:Array;
		private var totalScore:int;
		
		public function GamePanel() 
		{
			addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
		}
		
		private function onAddToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAddToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,distroy);
			onBack=new Signal();
			Parsers.enableAllBundled();
			view3d=new View3D();
			view3d.background=new BitmapTexture(new Img());
			view3d.camera.lens.far = -2000;
			addChild(view3d);
			
			dartsAry=new Array();
			aimAry=new Array();
			posAry=new Array();
			distanceAry=new Array();
			
			
			for(var i:int=0;i<GlobalData.counter;i++)
			{
				dartsLoader=new Loader3D();
				dartsLoader.z=-500
				dartsLoader.scale(30);
				dartsLoader.addEventListener(LoaderEvent.RESOURCE_COMPLETE,onDartComplete);
				dartsLoader.loadData(new DartsModel());
				view3d.scene.addChild(dartsLoader);
				dartsLoader.visible=false;
				dartsAry.push(dartsLoader);
					
				aim=new Mesh(new SphereGeometry(10),new ColorMaterial(0xff0000,0.5));
				aim.z=-20
				view3d.scene.addChild(aim);
				aim.visible=false;
				aimAry.push(aim);
			}
			
			targetLoader=new Loader3D();
			targetLoader.scale(48);
			targetLoader.addEventListener(LoaderEvent.RESOURCE_COMPLETE,onTargetComplete);
			targetLoader.loadData(new TargetModel());
			targetContainer=new ObjectContainer3D();
			targetContainer.addChild(targetLoader);
			view3d.scene.addChild(targetContainer);
			
			targetContainer.visible=false;
		}
		
		private function onDartComplete(e:LoaderEvent):void
		{
			var darts:*=Loader3D(e.target).getChildAt(0);
			darts.rotationY=90;
			darts.material=new TextureMaterial(new BitmapTexture(new M[GlobalData.target-1]));
		}
		
		private function onTargetComplete(e:LoaderEvent):void
		{
			targetContainer.visible=true;
			var target:*=Loader3D(e.target).getChildAt(0);
			target.rotationY=90;
			target.material=new TextureMaterial(new BitmapTexture(new M[GlobalData.target-1]));
			TweenLite.from(target,0.5,{z:10,ease:Circ.easeOut});
			onBack.dispatch('INIT');
		}
		
		private var dartsVisible:Boolean;
		private var currentDart:Loader3D;
		public function onUpData(frame:Frame):void
		{
			view3d.render();
			
			currentDart=dartsAry[currentCounter];
			var a:Mesh=aimAry[currentCounter];
			
			if(frame.tools.length>0&&!isPlay)
			{
				var tool=frame.tools[0];
				currentDart.visible=true;
				a.visible=true;
				
				currentDart.x=tool.tipPosition.x;
				currentDart.y=tool.tipPosition.y-300;
				currentDart.z=-tool.tipPosition.z-500;
				
				currentDart.rotationX=-tool.direction.pitch*LeapUtil.RAD_TO_DEG*1.2-currentDart.y/100;
				currentDart.rotationY=tool.direction.yaw*LeapUtil.RAD_TO_DEG*1.2-currentDart.x/100;
				
				a.x=currentDart.x+currentDart.rotationY*10;
				a.y=currentDart.y-currentDart.rotationX*10;
				a.z=-currentDart.rotationX/10+currentDart.rotationY/10-100;
				targetContainer.rotationX=currentDart.rotationX/6;
				targetContainer.rotationY=currentDart.rotationY/6;
				 
				if(currentDart.z-oldZ>25&&oldZ!=0&&currentDart.rotationX>-60&&currentDart.rotationX<60&&currentDart.rotationY>-50&&currentDart.rotationX<50)
				{ 
					a.x=currentDart.x+currentDart.rotationY*15+Math.random()*100;
					a.y=currentDart.y-currentDart.rotationX*15+Math.random()*100;
					trace(a.x,a.y)
					if(Math.abs(a.x)>520||Math.abs(a.y)>520)
					{
						dartsVisible=false;
					}else
					{
						dartsVisible=true;
					}
					
					isPlay=true;
					posAry.push([a.x,a.y]);
					TweenLite.to(currentDart,10/Math.abs(currentDart.z-oldZ),{x:a.x,y:a.y,z:10,onComplete:onCompleteHandler});
					oldZ=0;
					a.visible=false;
				}else
				{
					oldZ=currentDart.z;
					a.visible=true;
				}
			}else if(!isPlay)
			{
				oldZ=0;
				TweenLite.to(targetContainer,0.5,{rotationX:0,rotationY:0});
				currentDart.visible=false;
				a.visible=false;
			}
		}
		
		private function onCompleteHandler():void
		{
			targetContainer.addChild(currentDart);
			
			
			var distance:int=int(Math.sqrt(currentDart.x*currentDart.x+currentDart.y*currentDart.y));
			distanceAry.push(distance);
			TweenLite.to(currentDart,0.8,{rotationX:Math.random()*currentDart.rotationX,rotationY:Math.random()*currentDart.rotationX,ease:Back.easeOut});
			
			currentDart.visible=dartsVisible;
			if(currentCounter<GlobalData.counter-1)
			{
				currentCounter++;
				isPlay=false;
			}else
			{
				targetContainer.rotationX=targetContainer.rotationY=0;
				var tl:TimelineLite = new TimelineLite();
				for(var i:int=0;i<GlobalData.counter;i++)
				{
					tl.to(targetContainer, 0.5, {x:-posAry[i][0],y:-posAry[i][1],z:-600,ease:Back.easeOut,onStart:tweenStartHandler,onComplete:tweenCompleteHandler,onCompleteParams:[i]},"+=2")
				}
				tl.to(targetContainer, 0.5, {x:0,y:0,z:0,onComplete:allComplete},"+=2")
			}
		}
		
		private function tweenStartHandler():void
		{
			if(rp)
			{
				removeChild(rp);
				rp=null;
			}
		}
		
		private function tweenCompleteHandler(param:Object):void
		{
			targetContainer.removeChildAt(1);
			rp=new ResultPoint();
			addChild(rp);
			rp.x=stage.stageWidth/2;
			rp.y=stage.stageHeight/2;
			rp.txt.info.text=getScore(param);
		}
		
		private function getScore(num:Object):int
		{
			var score:int;
			var da:int=Math.abs(distanceAry[num]);
			
			for(var i:int=0;i<10;i++)
			{
				if(da>i*50-25&&da<(i+1)*50+25)
				{
					score=10-i;
				}
			}
			totalScore+=score;
			return score;
		}
		
		private function allComplete():void
		{
			var resultPanel:ResultPanel=new ResultPanel();
			addChild(resultPanel);
			resultPanel.x=stage.stageWidth/2;
			resultPanel.y=stage.stageHeight/2;
			resultPanel.bg.width=stage.stageWidth;
			resultPanel.bg.height=stage.stageHeight;
			resultPanel.resultText.textMc.txt.text='恭喜你\n共获得'+totalScore+'环';
			
			TweenLite.from(resultPanel.resultText,0.3,{alpha:0,y:resultPanel.resultText.y-50});
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDownHandler);
		}
		
		private function onKeyDownHandler(e:KeyboardEvent):void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDownHandler);
			onBack.dispatch('RESTART');
		}
		
		private function distroy(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE,distroy);
			onBack=null;
			
			while(view3d.scene.numChildren>0)
			{
				view3d.scene.removeChildAt(0);
			}
			removeChild(view3d);
			view3d=null;
		}
	}
}
