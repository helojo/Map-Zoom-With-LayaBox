package view {

	import com.hurlant.crypto.prng.Random;
	
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.map.MapLayer;
	import laya.map.TiledMap;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.ui.Box;
	import laya.ui.Label;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	import ui.test.TestPageUI;
	
	public class TestView extends TestPageUI {
		
		private var tiledMap:TiledMap;
		private var layer:MapLayer;//地图层
		private var spriteBox:Sprite;
	
		private var txt:Text;
		private var txt1:Text;
		private var txt2:Text;
		
		private var tf:Boolean;
		private var lastDistance:Number = 0;
	
		private var pressDown:Boolean;
		
		

		/**
		 * 
		 * !!!类型统一使用Number，即可以表示整形，也可以存浮点数！！！！！！！！！！！
		 * 
		 * 地图的缩放默认是以Rectangle的中心点，如地图是320320，但设置地图的区域是1000,1000,那么以500，500的中间点进行缩放，所以效果是不对的！
		 * pivot=0.5,0.5 中心点进行缩放
		 * 
		 * tiledMap.moveViewPort(100,100);这并不是移动 地图，而是移动视口，这个效果是将地图移出屏幕外-100，-100个单位！
		 * 
		 * pivot的取值范围，并不仅限于他的宽高区域内，可以是超出他的可视范围以外的
		 * 
		 * 
		 * tiledMap.mapSprite().pos((Laya.stage.width-tiledMap.width)/2,(Laya.stage.height-tiledMap.height)/2);
		 * 
		 * 让地图居中，其实就是让mapSprite居中显示
		 * 
		 * 
		 * 之前在真机上，发现边界移动有问题，显示不全，是因为设备的分辨率设置的和手机不同，比手机大一点，导致手机显示不全，并不是逻辑上的问题
		 * 
		 * 
		 * Note:图片放大以后，pivot并不能按放大后的处理，依然要按照原尺寸进行
		 * tiledMap.mapSprite().pivot
		 * 改变pivot会自动调整pos坐标,所以为了保证始终在原位置，要进行坐标的换算，比如：
		 * 
		 * 0.5,0.5时，位置在165,165,那么pivot(0,0)时，紧接着要设置pos位置为5,5即可！
		 * px-(pivot差*mapWidth)
		 * py-(pivot差*mapHeight)
		 * 结果为165-160=5,165-160=5
		 * 
		 * 如pivot(0,0)时，位置在5，5，那么pivot(0,5,0,5)要依然保持在5,5的位置，套用公式
		 * 5-160=-155,6-160=-155,结果并不准确 ，新的pivot大于原有的pivot，则+，否则-
		 * 
		 * 再比如：
		 * pivot(0.5,0.5)时，位置在165，165，如果现在调整为pivot(1,0),则应该是多少：
		 * 横向新的Pivot大于纵向的旧的pivot,则+，165+160=325
		 * 纵向新的Pivot小于旧的pivot，则-，165-160 = 5，最终位置为(325,0)
		 * 
		 * Px,py并不是0，1，这里要注意
		 * 
		 * x = px+或- px差
		 * y = px+或- py差map
		 * 
		 * 每次设置即可！
		 * 
		 * 
		 * 总结：
		 * 要实现哪些功能 ？
		 * 1.地图的绘制 2.拖拽地图 3.限制地图的上下左右边界 4.地图的放大 5.地图的局部放大 6.局部放大后的边界处理 7.碰撞检测，等角地图的碰撞检测 8.实现地面建筑的移动
		 * 
		 * 9.计算区域缩放时，取两指间的中心，先求中心点，然后需将中心点转换到图片上的坐标
		 * 
		 * 10.最后一个问题：不同中心点，移动以及缩放动态更新位置时，坐标计算是不同的，0，0是最方便的
		 * 
		 * 
		 * 
		 * 疑问点：pivot是和坐标无关的，地图pivot默认0，0点，绘制在屏幕的左上角，上下分别移动 一半的距离 后，
					 * 才顶齐在左上角，在U3D中并不是这种现象，好像屏幕坐标也是有Pivot的，0，0点是绘制在屏幕的中心，这个区别 有助于
					 * 理解各个坐标系，值得去搞清楚！
					 * 
					 * 
					 * 这里的屏幕不应该是指手机设备的屏幕，而是显示区域，该区域可以在任意位置，只是目前实现的形式是以手机屏幕为默认的
					 * 比如他可以显示在一个小电视画面中！
					 * 
					 * 将大的问题拆解成一个一个小问题来解决
		 */
		public function TestView() {
			//btn是编辑器界面设定的，代码里面能直接使用，并且有代码提示
			// btn.on(Event.CLICK, this, onBtnClick);
			// btn2.on(Event.CLICK, this, onBtn2Click);
				//Laya.stage.bgColor = "#FF0000";
			
			__JS__('Laya.CONCHVER && (conch.disableMultiTouch=false)');
			
			//this.buttonTest.on(Event.CLICK,this,scaleTest);
			
				tiledMap = new TiledMap();
			//tiledMap.createMap("res/tiledmap/e.json", new Rectangle(0, 0, Laya.stage.width, Laya.stage.height), null);

				//Laya.stage.width, Laya.stage.height
			
			tiledMap.createMap("res/tiledmap/f.json", new Rectangle(0,0, 1600,1600), Handler.create(this, mapLoaded), null);
			
			
			
		
			
			//tiledMap.moveViewPort(100,100);
			//tiledMap.mapSprite().pos(0,100);
		//	Laya.timer.frameLoop(1,this,test);
			
			Laya.stage.on(Event.MOUSE_DOWN, this, mouseDown);
			Laya.stage.on(Event.MOUSE_UP, this, mouseUp);
			Laya.stage.on(Event.MOUSE_MOVE,this,mouseMove);
			

			
			spriteBox = new Sprite();
			spriteBox.width = 30;
			spriteBox.height =30;
			//spriteBox.graphics.drawRect(0,0,sprite.width,sprite.height,"#ff00ff");
			Laya.stage.addChild(spriteBox);
			spriteBox.zOrder = 1000;//地图的默认zorder是多少？
			
			//tiledMap.getLayerByIndex(0).addChild(sprite);
//			var mapLayer:MapLayer = tiledMap.getLayerByIndex(0);
//			trace("mapLayer:"+mapLayer);
			
			Laya.stage.on("click", this, onStageClick);
			//sprite.graphics.drawRect(0,0,sprite.width,sprite.height);

			
		
		}
		
		
		var xxx:int = 0;
		
		private function scaleTest():void
		{
			//tiledMap.mapSprite().pivot(MapWidth()/2,MapHeight()/2);
			//xxx+=5;
			//tiledMap.scale(tiledMap.mapSprite().scaleX+0.1);//
			t10 = false;
			tiledMap.mapSprite().scale(tiledMap.mapSprite().scaleX+0.1,tiledMap.mapSprite().scaleX+0.1,false);
			//tiledMap.mapSprite().scale(1.2,1.2);
			//trace("x:"+(tiledMap.mapSprite().scaleX));
			
			//tiledMap.mapSprite().size(MapWidth(),MapHeight());
			
			
		}
		
		var tc:Boolean;
		var tb:int;
		
		var prePivotX:Number;
		var prePivotY:Number;
		
		private function test3():void
		{
			var Range = MP().width - 0;
			var Rand = Math.random();
			var randomPX = 0 + Math.round(Rand * Range); //四舍五入
			var randomPY = 0+Math.round(Rand*Range);
			//num = 320;
			
			t10 = false;//用于控制鼠标点击，计算鼠标在图片上的位置，坐标转换！
			
			randomPX = targetPivotX;
			randomPY = targetPivotY;
			
			MP().pivot(targetPivotX,targetPivotY);
			
			//trace("pivot:"+num+","+prePivotX);
			
			trace("random px:"+randomPX+",random py:"+randomPY);
			
			//重新设置坐标点
			var newX:int = 0;
			var newY:int = 0;
			if(randomPX>=prePivotX)
			{
				/**
				 * 总算是求得了结果：
				 * num,perPivot是原始大小，坐标计算时，要*上缩放的倍数
				 */
				newX = MP().x+Math.abs(randomPX-prePivotX)*MP().scaleX;
			}else
			{
				newX = MP().x-Math.abs(randomPX-prePivotX)*MP().scaleX;
			}
			if(randomPY>=prePivotY)
			{
				newY = MP().y+Math.abs(randomPY-prePivotY)*MP().scaleX;
			}else
			{
				newY = MP().y-Math.abs(randomPY-prePivotY)*MP().scaleX;
			}
			
			MP().pos(newX,newY);
			
			//txt2.text = ("px:"+targetPivotX+",py:"+targetPivotY);
			//保存新的中心点数据
			prePivotX = randomPX;
			prePivotY = randomPY;
			
			
			spriteBox.graphics.clear();
			spriteBox.graphics.drawRect(MP().x,MP().y,spriteBox.width,spriteBox.height,"#FF5500",5);
			
			
		}
		
		private function test2():void
		{
			//tiledMap.mapSprite().pivot(MapWidth()/2,MapHeight()/2);
			//xxx+=5;
			//tiledMap.scale(tiledMap.mapSprite().scaleX+0.1);//
			//tiledMap.mapSprite().pos(0,0);
			
			//x = px+或- px差
		   //y = px+或- py差
			
			//320,320
			
			//tiledMap.mapSprite().pos(320+MapWidth()-MapWidth()/2,320-MapHeight()/2);
			
			
			//if(!tc)
			{
//				tiledMap.mapSprite().pivot(MapWidth(),0);
//				tc = true;
//				
//				tiledMap.mapSprite().pos(320+(MapWidth()-MapWidth()/2),320-(MapHeight()-MapHeight()/2));
				
				
				switch(tb)
				{
					case 0:
						/**
						 * 改变pivot(0.5,0.5)->(1.0,0)
						 * h:> + 320+160
						 * v:< 320-
						 */
						tiledMap.mapSprite().pivot(144,144);
						/**
						 * 此时调整了图像的坐标，再次设定位置
						 * 如调整到左下角
						 */
						tiledMap.mapSprite().pos(304,304);
						tb++;
						break;
					case 1:
						trace(tiledMap.mapSprite().x+","+tiledMap.mapSprite().y);
						
						tiledMap.mapSprite().pivot(88,88);
						//由1，0，变为0.1
						/**
						 * 目前为止，变更坐标应该是OK了，那么下一步测试放大后，设置Pivot后，缩放的逻辑是否正常
						 * 1.设置不同的pivot位置，并绘制出缩放点，并进行点击缩放
						 */
						tiledMap.mapSprite().pos(304-(144-88)*MP().scaleX,304-(144-88)*MP().scaleY);
						break;
					
				}
				
				
				//tiledMap.mapSprite().pos(MapWidth()/2,MapHeight()/2);
				
				//Laya.timer.frameLoop(1, this, scaleTest2);
				
			}
//			else
//			{
//				//1,0变0.5，0.5
//				//tiledMap.mapSprite().pivot(MapWidth()/2,MapHeight()/2);//
//				
//				tiledMap.mapSprite().pivot(MapWidth()/2,MapHeight()/2);//
//				tiledMap.mapSprite().pos(480-(MapWidth()-MapWidth()/2),160+(MapHeight()-MapHeight()/2));
//				tc= false;
//				
//				//tiledMap.mapSprite().pos(320-MapWidth()-MapWidth()/2,320+MapHeight()/2);
//				
//				//tiledMap.mapSprite().x = 320+MapWidth()/2;
//			}
			//txt1.text = tiledMap.mapSprite().x+","+tiledMap.mapSprite().y;
			txt1.text = tiledMap.mapSprite().width+","+tiledMap.mapSprite().height;
			
			trace("xx:"+tiledMap.mapSprite().x+","+tiledMap.mapSprite().y);
		}
		
		
		private function scaleTest2():void
		{
			tiledMap.mapSprite().rotation+=2;
			
		}
		private function getDistance(points:Array):Number
		{
			var distance:Number = 0;
			if (points && points.length == 2)
			{
				var dx:Number = points[0].stageX - points[1].stageX;
				var dy:Number = points[0].stageY - points[1].stageY;
				
				distance = Math.sqrt(dx * dx + dy * dy);
			}
			return distance;
		}
		
		/**
		 * 获取中心点
		 */
		private function getCenterPoint(x:Number,y:Number):Number{
			
			return (Math.abs(x)+Math.abs(y))/2;
		}
		
		
		private var px:Number;
		private var py:Number;
		private var diffOffsetX:Number;
		private var diffOffsetY:Number;
		
		public var t1:int;
		
		var targetPivotX:Number = 0;
		var targetPivotY:Number = 0;
		
		var t10:Boolean;
		
		private function mouseDown(e:Event=null):void
		{
			trace("down");
		
			
			/**
			 * 计算局部缩放的中心点，介于两指之间，求两点的中心点坐标
			 * 
			 * 设2个坐标分别为A(X1,Y1) B(X2,Y2)
				 则两点的中心坐标为C((X1+X2)/2,(Y1+Y2)/2)
			 * 
			 * 角色点击的位置，即鼠标占击的位置坐标要转换到地图坐标！
			 * 
			 * pivot的取值范围为x(0,width),y(0,height)，所以均是以左上角
			 * 
			 * 刚才有个问题折磨了我好久，关于坐标轴上的两点，求他们之间的差值，直接相减求出差值，就得出了在屏幕上的实际坐标了！
			 * ----50----60---,60-50=10 60-10=50，纵向也是，通过差值求第一个值，弱智的问题
			 * 
			 * 鼠标点击地图，求在地图上的中心点
			 * px-(spx-mx)=newx
			 * py-(spy-my)=newy
			 * 如果值是负的，说明并没有点击在地图上
			 * 
			 * 
			 */
//			trace("mx:"+Laya.stage.mouseX+",my:"+Laya.stage.mouseY);
//			trace("spriteX:"+MP().x+",spriteY:"+MP().y);
//			var x:int = Math.abs(MP().x)+Laya.stage.mouseX;
//			var y:int = Math.abs(MP().y)+Laya.stage.mouseY;
//			trace("destX:"+x+","+"destY:"+y);
			
			
		//	spriteBox.pos(Laya.stage.mouseX,Laya.stage.mouseY);
			
//			spriteBox.graphics.clear();
//			spriteBox.graphics.drawRect(Laya.stage.mouseX,Laya.stage.mouseY,spriteBox.width,spriteBox.height,"#FF0000",5);
//			
			if(false)
			{
				
			if(!t10)
			{
				/**
				 * 求单点的缩放区域，放大的情况下如何点在正确的位置上？
				 * pivot不参与放大的运算，所以图片你放大100倍，pivot的范围
				 * 依然只是原尺寸的大小，所以100倍的坐标要/缩放比例来求得
				 * 原图片尺寸下的坐标！
				 * 
				 */
				t10 = true;
				if(Laya.stage.mouseX>=MP().x)
				{
					/**
					 * 如果是大于当前的X坐标
					 * targetPx = px+Math.abs(mx-spx);
					 * 限定条件是小于0或是大于图像原尺寸的宽度，则不在点击的范围之内
					 * 
					 * 如果图片处于放大状态，要/缩放比例以计算原图尺寸的坐标，如2x2的图，你放大到4x4，但pivot是和放大无关的，你鼠标点到4,4的位置，转换到原
					 * 图就是2,2的位置，因为你点的图是经过放大的
					 */
					targetPivotX = prePivotX+Math.abs(Laya.stage.mouseX-MP().x)/MP().scaleX;
					if(targetPivotX>MP().width)
					{
						trace("pivot x 超出限定区域");
					}
					
				}else
				{
					targetPivotX = prePivotX-Math.abs(Laya.stage.mouseX-MP().x)/MP().scaleX;
					
					if(targetPivotX<0)
					{
						trace("pivot x 小于限定区域");
					}
				}
				
				if(Laya.stage.mouseY>=MP().y)
				{
					/**
					 * 如果是大于当前的X坐标
					 * targetPx = px+Math.abs(mx-spx);
					 * 限定条件是小于0或是大于图像原尺寸的宽度，则不在点击的范围之内
					 */
					targetPivotY = prePivotY+Math.abs(Laya.stage.mouseY-MP().y)/MP().scaleY;
					if(targetPivotY>MP().height)
					{
						trace("pivot y 超出限定区域");
					}
					
				}else
				{
					targetPivotY = prePivotY-Math.abs(Laya.stage.mouseY-MP().y)/MP().scaleY;
					
					if(targetPivotY<0)
					{
						trace("pivot y 小于限定区域");
					}
				}
				
				
				trace("targetPX:"+targetPivotX+",targetPY:"+targetPivotY);
				
				
			}
			
			
			}
			
			
			//MP().pivot(targetPivotX,targetPivotY);
			
			
			var touches:Array = e.touches;
			if(touches && touches.length == 1)
			{
				txt.text = "down"+t1;
//				t1++;
				
				pressDown = true;
				
				px =touches[0].stageX;//Laya.stage.mouseX;
				py =touches[0].stageY;// Laya.stage.mouseY;
				
//				px =touches[0].stageX;//Laya.stage.mouseX;
//				py =touches[0].stageY;// Laya.stage.mouseY;
				
				diffOffsetX = px-tiledMap.mapSprite().x;
				diffOffsetY = py-tiledMap.mapSprite().y;
				
				tiledMap.mapSprite().pos(px-diffOffsetX,py-diffOffsetY);
				
				//txt2.text = "touch1 pressed";
				
				
				
			}
			
			if(touches && touches.length == 2)
			{
				/**
				 * 当我一个手指按下的时候，屏幕处于可以移动状态，如果我两指按下，就取消屏幕 移动 状态，
				 * 变成缩放状态，这时候，放开一只手指，地图也不可以继续移动，只能重新按下，再进行移动 (参考QQ空间农场)
				 */
				pressDown = false;//两指的情况下，变为缩放，而不再移动 
				
				lastDistance = getDistance(touches);
				
//				var lastDistance2:int = Math.sqrt(Math.abs((touches[0].stageX - touches[1].stageX)
//					* (touches[0].stageX - touches[1].stageX)+(touches[0].stageY - touches[1].stageY)
//					* (touches[0].stageY - touches[1].stageY)));
//				
//				
//				txt.text = "last:"+lastDistance+",new:"+lastDistance2;
				
				var touchCenterX:Number = getCenterPoint(touches[0].stageX,touches[1].stageX);
				var touchCenterY:Number = getCenterPoint(touches[0].stageY,touches[1].stageY);
				
				var tPivotX:Number = getPivotXInMap(touchCenterX);
				var tPivotY:Number = getPivotYInMap(touchCenterY);
				
//				var t1PivotX:Number = getPivotXInMap(touches[0].stageX);
//				var t1PivotY:Number = getPivotYInMap(touches[0].stageY);
//				
//				var t2PivotX:Number = getPivotXInMap(touches[1].stageX);
//				var t2PivotY:Number = getPivotYInMap(touches[1].stageY);
				
				//计算两指之间的中心点
				/**
				 * 求中心点：
				 * 之前一直做错了，我是将屏幕上任意一点做为中心点，并转换成图像坐标，以调整新的位置
				 * 那么应该是先求屏幕上两指间的中心点，然后再将该点转换为图像的中心点，之前错误
				 * 的做法是将分别将两点计算为中心点，再取中心，这是不对的！
				 * 
				 
				 * 
				 */
//				var centerPovitX:Number = getCenterPoint(t1PivotX,t2PivotX);
//				var centerPovitY:Number = getCenterPoint(t1PivotY,t2PivotY);
				
//				txt.graphics.drawCircle(MP().x+t1PivotX,t1PivotY,10,"#FF0000","#FFFF00",2);
//				txt.graphics.drawCircle(t2PivotX,t2PivotY,10,"#FFFF00","#FFFF00",2);
				
				//txt2.text =""+t1PivotX+","+t1PivotY+","+t2PivotX+","+t2PivotY+",("+centerPovitX+","+centerPovitY+")";
				
				
				
//				//重新设置中心点
				targetPivotX = tPivotX;
				targetPivotY = tPivotY;
				
				test3();
				
				//txt2.text = "x:"+targetPivotX+",y:"+targetPivotY;
				
			
//				
//				trace("tPivotX:"+tPivotX+",tPivotY:"+tPivotY);
				
				//test3();
			//	Laya.stage.on(Event.MOUSE_MOVE, this, onMouseMove);
			}
			
			//绘制参考线
			/**
			 * 是否要将缩放的位置，换算成地图中某一个具体格子的点，并取中心进行缩放？
			 * 
			 */
//			txt.graphics.clear();
//			
//			
//			var p = new Point(0, 0);
//			layer.getTilePositionByScreenPos(Laya.stage.mouseX, Laya.stage.mouseY, p);
//			layer.getScreenPositionByTilePos(Math.floor(p.x), Math.floor(p.y), p);
//			//txt.graphics.drawRect(p.x,p.y,32,32,"#FF00FF",2);
//			//H
//			txt.graphics.drawLine(0,p.y+16,SW(),p.y+16,"#FF0000",2);
//			txt.graphics.drawLine(p.x+16,0,p.x+16,SH(),"#FF0000",2);
			
			
			
			
			//V
		//	txt.graphics.drawLine(Laya.stage.mouseX,0,Laya.stage.mouseX,SH(),"#FF0000",2);
			//Circle
			//txt.graphics.drawCircle(Laya.stage.mouse
			
			
		
		}
		
		/**
		 * 获取点击位置的中心点X
		 */
		private function getPivotXInMap(val:Number):Number
		{
			
			if(val>=MP().x)
			{
				
				return prePivotX+Math.abs(val-MP().x)/MP().scaleX;
//				if(targetPivotX>MP().width)
//				{
//					trace("pivot x 超出限定区域");
//				}
				
			}else
			{
				 return prePivotX-Math.abs(val-MP().x)/MP().scaleX;
				
//				if(targetPivotX<0)
//				{
//					trace("pivot x 小于限定区域");
//				}
			}
		}
		
		/**
		 * 获取点击位置的中心点Y
		 */
		private function getPivotYInMap(val:Number):Number{
			if(val>=MP().y)
			{
				
				return prePivotY+Math.abs(val-MP().y)/MP().scaleY;
//				if(targetPivotY>MP().height)
//				{
//					trace("pivot y 超出限定区域");
//				}
				
			}else
			{
				return prePivotY-Math.abs(val-MP().y)/MP().scaleY;
				
//				if(targetPivotY<0)
//				{
//					trace("pivot y 小于限定区域");
//				}
			}
		}
		
		
		private function checkPivotX(val:Number):Boolean
		{
			if(val>MP().width)
			{
				trace("pivot x 超出限定区域");
				return false;
			}
			
			if(val<0)
			{
				trace("pivot x 小于限定区域");
				return false;
			}
			
			return true;
		}
		
		
		private function checkPivotY(val:Number):Boolean
		{
			if(val>MP().height)
			{
				trace("pivot y 超出限定区域");
				return false;
			}
			
			if(val<0)
			{
				trace("pivot y 小于限定区域");
				return false;
			}
			
			return true;
		}
		
		private function mouseUp():void
		{
			trace("up");
			pressDown =false;
		}
		
		private function mouseMove(e:Event=null):void
		{
//			if(true)
//			{
//				return;
//			}
			var touches:Array = e.touches;
			
			//处理缩放
			if(touches && touches.length==2)
			{
				//txt.text= "缩放处理";
				//求两指之间的绝对值
				var distance:Number = getDistance(e.touches);

				const factor:Number = 0.05;
				
				//	txt.text = "val:"+(distance - lastDistance);
				
				
				if(distance>lastDistance)
				{
					//txt.text = "放大:"+lastDistance+","+distance;
					UpdateScale(factor);
					
				//	tiledMap.mapSprite().scale(tiledMap.mapSprite().scaleX+factor,tiledMap.mapSprite().scaleX+factor);
					
				}else if(distance<lastDistance)
				{
					//txt.text = "缩小:"+lastDistance+","+distance;
					UpdateScale(-factor);
					
					//tiledMap.mapSprite().scale(tiledMap.mapSprite().scaleX-factor,tiledMap.mapSprite().scaleX-factor);
				}
				
				
				lastDistance = distance;
			}
			else
			if(touches && touches[0])//拖动实现
			{
				if(pressDown){
					t1++;
					px =Laya.stage.mouseX;
					py = Laya.stage.mouseY;
					tiledMap.mapSprite().pos(px-diffOffsetX,py-diffOffsetY);
					//限制移动边界
					if(tiledMap.mapSprite().x>=TargetPovitXByScale())//尺寸放大以后，pivot的值也要进行放大，否则移动达不到边界
					{
						tiledMap.mapSprite().x = TargetPovitXByScale();
					}
					
					if(tiledMap.mapSprite().y>=TargetPovitYByScale())
					{
						tiledMap.mapSprite().y =TargetPovitYByScale();
					}
					
					//右边界限制 
					//var restrictRightVal:int = Math.abs(Laya.stage.width-MapWidth());//-TiledWidth()
					
					/**
					 * 地图和屏幕的宽度差
					 */
					var diffWidthHorizontal:int = Laya.stage.width-MapWidth();
					
					/**
					 * 如果地图的宽度没有显示区域的大，那么不应该移动
					 */
					if(diffWidthHorizontal>=0)//说明屏幕的尺寸大于地图的尺寸
					{
						diffWidthHorizontal = 0;
					}
					
					/**
					 * 疑问点：pivot是和坐标无关的，地图pivot默认0，0点，绘制在屏幕的左上角，上下分别移动 一半的距离 后，
					 * 才顶齐在左上角，在U3D中并不是这种现象，好像屏幕坐标也是有Pivot的，0，0点是绘制在屏幕的中心，这个区别 有助于
					 * 理解各个坐标系，值得去搞清楚！
					 */
//					if(tiledMap.mapSprite().x<TargetPovitXByScale()-Math.abs(diffWidthHorizontal))
//					{
//						
//						//tiledMap.mapSprite().x = -restrictRightVal;
//						tiledMap.mapSprite().x = TargetPovitXByScale()-Math.abs(diffWidthHorizontal);
//					}
					
					
					/**
					 * 拖拽的区域算法进行了优化：
					 * 限制在显示区域 内（这里默认是手机的设备屏幕）移动，那么移动的XY坐标只要小于显示区域和地图的宽高差+pivot即可，
					 * 理解了pivot,就不要再认为图像的左上角是原点了，默认情况下，pivot的值就是相对于屏幕0，0的原点
					 * 比如10，0原点，地图和显示区域差是30，那么x<=-30理论就可以了，但pivot是10，小于10就出屏了，所以-30+10 小于-20时就要限制
					 * 这块理解上要转变一下思路才行
					 * 
					 * 那么在进行缩小时，因为坐标是不会变化的，变会的只是尺寸，而尺寸的变化会影响显示区域，会出现地图的某个角（因为是等比缩放），显示在”显示区域内“
					 * 他应该限制在显示区域的边缘，所以这里要动态的改变x,y坐标以及解决该问题
					 * 
					 * 
					 * 这里就有一个面试题可以问了：一个图像位于屏幕的左上角，紧挨着屏幕，请问这张图片的坐标是多少，如果回答是0，0，证明对不理解 pivot，回答 是
					 * pivotx,pivoty,这才是正确的！
					 * 
					 * 另一点，碰撞检测也是要基于pivot的，总之，0，0点只是默认的pivot设定，不要认为是固定的！
					 * 
					 * 碰撞公式也要基于pivot,后面写写算法
					 * 
					 * 
					 */
					var diffMW_SW:Number = SW()-MapWidth();//基于显示区域 内移动，应该是屏幕 的宽度减于地图的宽度
					//txt2.text = "diffMW_SW:"+diffMW_SW;
					if(MP().x<=diffMW_SW+TargetPovitXByScale())
					{
						MP().x = diffMW_SW+TargetPovitXByScale();
					}
//					txt2.text = "diff:"+TargetPovitXByScale();
//					if(pivotToMapWidth<=pivotToScreenWidth)
//					{
//						MP().x+=pivotToScreenWidth-pivotToMapWidth;
//					}
					
					//下边界限制 
					//var restrictBottomVal:int = Math.abs(Laya.stage.height-MapHeight());
					/**
					 * 地图和屏幕的高度比
					 */
//					var diffHeightVertical:int = Laya.stage.height-MapHeight();
//					if(diffHeightVertical>=0)//地图的尺寸小于视口尺寸（默认为屏幕 ）时，不进行移动
//					{
//						diffHeightVertical = 0;
//					}
////					if(tiledMap.mapSprite().y<-restrictBottomVal)
////					{
////						tiledMap.mapSprite().y = -restrictBottomVal;
////					}
//					if(tiledMap.mapSprite().y<TargetPovitYByScale()-Math.abs(diffHeightVertical))
//					{
//						tiledMap.mapSprite().y = TargetPovitYByScale()-Math.abs(diffHeightVertical);
//					}
					
					var diffMH_SH:Number = SH()-MapHeight();//基于显示区域 内移动，应该是屏幕 的宽度减于地图的宽度
					//txt2.text = "diffMW_SW:"+diffMW_SW;
					if(MP().y<=diffMH_SH+TargetPovitYByScale())
					{
						MP().y=diffMH_SH+TargetPovitYByScale();
					}
					
					txt.text = tiledMap.mapSprite().x+","+tiledMap.mapSprite().y;
					
					//tiledMap.mapSprite().pos(Laya.stage.mouseX,Laya.stage.mouseY);
				}
			}
			
		}
		
		/**
		 * 问题的难点就在于，哪些实现是不需要根据放大和缩小去计算pivot的，哪些是需要的，
		 * 比如定位是不需要的，边界限制则需要
		 * 
		 * 不论图片放大多少倍，他的中心点的位置和放大无关的！
		 */
		private function TargetPovitXByScale():Number
		{
			return targetPivotX*MP().scaleX;
		}
		
		private function TargetPovitYByScale():Number
		{
			return targetPivotY*MP().scaleY;
		}
		
		private function MX():int
		{
			return tiledMap.mapSprite().x;
		}
		
		private function MY():int
		{
			return tiledMap.mapSprite().y;
		}
		
		private function SW():int{
			return Laya.stage.width;
		}
		
		private function SH():int{
			return Laya.stage.height;
		}
		
		private function UpdateScale(x:Number):void
		{
			tiledMap.mapSprite().scale(tiledMap.mapSprite().scaleX+x,tiledMap.mapSprite().scaleX+x);
			if(tiledMap.mapSprite().scaleX<=1)
			{
				tiledMap.mapSprite().scaleX = 1;
				tiledMap.mapSprite().scale(1,1);
			}
			else
				if(tiledMap.mapSprite().scaleX>=2)
				{
					tiledMap.mapSprite().scaleX = 2;
					tiledMap.mapSprite().scale(2,2);
				}

			
			/**
			 * 缩小的时候，并不进行坐标的计算，所以四个角很可能会进入到屏幕内，导致背景透出来，
			 * 这时候需要动态的调整坐标！
			 * 
			 * 无论地图多大，缩放比例不会小于1，那么我们只需要去控制XY坐标即可
			 */
			//缩小
//			if(x<0)
//			{
//				txt.text= "scaling.....:"+(MX()+MapWidth())+","+SW();
//				if(MX()+MapWidth()<=SW())
//				{
//					var deltaH:int = (SW()-(MX()+MapWidth()));
//					txt.text ="diff:"+ deltaH;
//					if(deltaH!=0)
//					{
//						tiledMap.mapSprite().x+= deltaH;
//					}
//					
//					//Laya.timer.scale = 0;
//				}
//				
//				if(MY()+MapHeight()<=SH())
//				{
//					var deltaV:int = (SH()-(MY()+MapHeight()));
//					if(deltaV!=0)
//					{
//						tiledMap.mapSprite().y+= deltaV;
//					}
//					
//				}
//			}
			
			/**
			 * 缩放时，坐标是不变的，只改变尺寸，尺寸的改变会影响显示区域，因为等比例缩放原因，会使地图的边角出现在显示区域内，正常的
			 * 效果是我们要限制地图的边角在显示区域的边角，这里需要实时的计算宽高来调整坐标+-
			 *
			 */
//			if(tiledMap.mapSprite().x>=TargetPovitXByScale())//尺寸放大以后，pivot的值也要进行放大，否则移动达不到边界
//			{
//				tiledMap.mapSprite().x = TargetPovitXByScale();
//			}
//			
//			if(tiledMap.mapSprite().y>=TargetPovitYByScale())
//			{
//				tiledMap.mapSprite().y =TargetPovitYByScale();
//			}
			
			if(x<0)
			{
				
				//txt2.text = "x:"+MP().x;
				
//				if(tiledMap.mapSprite().x>=TargetPovitXByScale())//尺寸放大以后，pivot的值也要进行放大，否则移动达不到边界
//								{
//									tiledMap.mapSprite().x = TargetPovitXByScale();
//								}
//								
//								if(tiledMap.mapSprite().y>=TargetPovitYByScale())
//								{
//									tiledMap.mapSprite().y =TargetPovitYByScale();
//								}
					
				/**
				 * 这里想了很久，不知如何处理，缩放的时候，影响哪个参数？
				 * 首先，坐标不变，在移动逻辑中，左和上两个边界的限定条件是什么，默认情况下，x或y大于0，就进入到显示区域了，
				 * 但这0,0其实是pivot的值，所以x或y >= pivot就不允许再稳定了
				 * 那么当移动到地图边界的时候，此时的x或y被强制设置为pivot，这时候你缩放地图，pivot的值改变了，比如由150变为149
				 * 按等比缩放，会有一条缝隙出来，那么让X或Y强制等于新的pivot,继续让他们显示在边界就OK了，原来如此
				 */
				//左边界
				if(tiledMap.mapSprite().x>=TargetPovitXByScale())//尺寸放大以后，pivot的值也要进行放大，否则移动达不到边界
				{
					tiledMap.mapSprite().x = TargetPovitXByScale();
				}
				
				//上边界
				if(tiledMap.mapSprite().y>=TargetPovitYByScale())
				{
					tiledMap.mapSprite().y =TargetPovitYByScale();
				}
				
				//右边界
				var diffSW_MW:Number = SW()-MapWidth();//计算宽度差
				if(MX()<=diffSW_MW+TargetPovitXByScale())
				{
					//右边界进入屏幕
					MP().x = diffSW_MW+TargetPovitXByScale();
				}
				
				//下边界
				var diffSH_MH:Number = SH()-MapHeight();//计算高度差
				if(MY()<=diffSH_MH+TargetPovitYByScale())
				{
					//下边界进入屏幕
					MP().y = diffSH_MH+TargetPovitYByScale();
				}
				
			}
			
			
			
			
			
//			var diffMW_SW:Number = SW()-MapWidth();//基于显示区域 内移动，应该是屏幕 的宽度减于地图的宽度
//			//txt2.text = "diffMW_SW:"+diffMW_SW;
//			if(MP().x<=diffMW_SW+TargetPovitXByScale())
//			{
//				MP().x+=Math.abs(MP().x)-Math.abs(diffMW_SW);
//			}
//			
//			var diffMH_SH:Number = SH()-MapHeight();//基于显示区域 内移动，应该是屏幕 的宽度减于地图的宽度
//			//txt2.text = "diffMW_SW:"+diffMW_SW;
//			if(MP().y<=diffMH_SH+TargetPovitYByScale())
//			{
//				MP().y+=Math.abs(MP().y)-Math.abs(diffMH_SH);
//			}
			
		}
		private function MapWidth():int
		{
			return tiledMap.width*tiledMap.mapSprite().scaleX;
		}
		private function MapHeight():int
		{
			return tiledMap.height*tiledMap.mapSprite().scaleX;
		}
		
		private function TiledWidth():int
		{
			return tiledMap.tileWidth*tiledMap.mapSprite().scaleX;
		}
		
		private function onStageClick(e:*=null):void
		{
			var p:Point = new Point(0, 0);
			layer.getTilePositionByScreenPos(Laya.stage.mouseX, Laya.stage.mouseY, p);//根据当前鼠标的位置，获取图块的位置
			
			layer.getScreenPositionByTilePos(Math.floor(p.x), Math.floor(p.y), p);//根据图块的位置，获取屏幕 坐标的位置
			
			//txt.text = p.toString();
			
			//tiledMap.moveViewPort(-100,-100);
			
		//	trace("Laya.stage.width:"+(tiledMap.width-Laya.stage.width)/2,(tiledMap.height-Laya.stage.height)/2);
			
			//layer.pos(-133,-(tiledMap.height-Laya.stage.height)/2);
			//layer.pos(0,0);
			//layer.pos(100,100);
//			layer.rotation =30;
			
			//tiledMap.scale+=0.02;
			
//			tiledMap.scale =!tf?2:1;
			
//			tf = !tf;
		}
		
		private function MP():Sprite
		{
			return tiledMap.mapSprite();
		}
		private function mapLoaded(e:*=null):void
		{
			layer = tiledMap.getLayerByIndex(0);
			
			var radiusX:Number = 32;
			var radiusY:Number = Math.tan(180 / Math.PI * 30) * radiusX;
			var color:String = "#FF7F50";
			//scaleTest();
		
			
			/**
			 * 地图默认的Pivot=0，0，左角上，方便定位到地图中指定的位置到屏幕中间！
//			 */
			tiledMap.mapSprite().size(1600,1600);//设定地图的宽和高，只用于碰撞检测  、、320,320
			tiledMap.mapSprite().pos(0,0);//320,320
			
			//tiledMap.mapSprite().pivot(MP().width/2,MP().height/2);
			tiledMap.mapSprite().pivot(0,0);
			
			targetPivotX = 0;//MP().width/2;
			targetPivotY = 0;//MP().height/2;
			
			//测试数据
//			tiledMap.mapSprite().size(320,320);//设定地图的宽和高，只用于碰撞检测  、、320,320
//			tiledMap.mapSprite().pos(40,160);//320,320
//			
//			tiledMap.mapSprite().pivot(MP().width/2,MP().height/2);
//			//tiledMap.mapSprite().pivot(0,0);
//			
//			targetPivotX = MP().width/2;
//			targetPivotY = MP().height/2;
			
			prePivotX = targetPivotX;
			prePivotY = targetPivotY;
			
			
			
			//tiledMap.mapSprite().pos(0,0);
			
			//sprite = new Sprite();
			
			
			//tiledMap.scale = 10;//地图缩放
			

			//_viewPortWidth,_viewPortHeight相对于地图，默认0，0，_viewPortWidth，_viewPortHeight 等于地图的宽和高，
			//经时，如果地图放大2倍，那么vt,vh并不是2部，
			
			//sprite.graphics.drawRect(0,0,tiledMap,tiledMap.viewPortHeight,"#00ff00");
			
			
			
			
			//tiledMap.mapSprite().pos((Laya.stage.width-tiledMap.width)/2,(Laya.stage.height-tiledMap.height)/2);
			
			//地图的宽高
			
			txt = new Text();
			//txt.text = tiledMap.width+","+tiledMap.height;
			
			//txt.text = tiledMap.viewPortX+","+tiledMap.viewPortY;
			
			txt.text = tiledMap.width+","+tiledMap.height;
			txt.fontSize= 30;
			txt.color = "#00FF00";
			//地图的宽，高=行*tiledWidth,列*tiledHeight
			//txt.on(Event.DOUBLE_CLICK,this,scaleTest);
			txt.on(Event.CLICK,this,scaleTest);
			//txt.on(Event.DOUBLE_CLICK,
			
			txt1 = new Text();
			txt1.text = "hello";
			txt1.fontSize= 30;
			txt1.color = "#0000FF";
			txt1.pos(SW()-100,SH()-100);
			txt1.on(Event.CLICK,this,test2);
			
			Laya.stage.addChild(txt);
			Laya.stage.addChild(txt1);
			
			txt2 = new Text();
			txt2.text = "random pivot";
			txt2.fontSize= 30;
			txt2.color = "#FF0f0f";
			txt2.pos(SW()-400,SH()-60);
			txt2.on(Event.CLICK,this,test3);
			Laya.stage.addChild(txt2);
			
			txt1.text = tiledMap.mapSprite().width+",,"+tiledMap.mapSprite().height;
			
			txt2.graphics.drawRect(MP().x,MP().y,MP().width,MP().height,"#FF0000","#FF00FF",2);
			txt2.zOrder = 10000;
			
//			var txt1:Text = new Text();
//			txt.fontSize= 30;
//			txt.color = "#00FF00";
//			txt.pos(200,200);
//			
//			txt.on(Event.CLICK,this,scaleTest);
			
			if(Browser.onPC)
			{
				txt.text = "pc";
			}else if(Browser.onAndriod)
			{
				txt.text = "Android";
			}else if(Browser.onIOS)
			{
				txt.text = "iOS";
			}
			
			
			/**
			 * 目前的缩放并没有使用tiledMap的pivot，均是主mapsprite自身精灵的操作
			 * 稍后要改为tiledmap本身参数的操作形式
			 */
			
//			sprite.graphics.drawLine(0, 0, -radiusX, radiusY, color);
//			sprite.graphics.drawLine(0, 0, radiusX, radiusY, color);
//			sprite.graphics.drawLine(-radiusX, radiusY, 0, radiusY * 2, color);
//			sprite.graphics.drawLine(radiusX, radiusY, 0, radiusY * 2, color);
		//	Laya.stage.addChild(sprite);
		}
		
		
		
		private function test():void
		{
			trace("map:"+tiledMap.tileWidth);
		}
		
		private function onBtnClick(e:Event):void {
			//手动控制组件属性
			// radio.selectedIndex = 1;
			// clip.index = 8;
			// tab.selectedIndex = 2;
			// combobox.selectedIndex = 0;
			// check.selected = true;
		}
		
		private function onBtn2Click(e:Event):void {
			//通过赋值可以简单快速修改组件属性
			//赋值有两种方式：
			//简单赋值，比如：progress:0.2，就是更改progress组件的value为2
			//复杂复制，可以通知某个属性，比如：label:{color:"#ff0000",text:"Hello LayaAir"}
			// box.dataSource = {slider: 50, scroll: 80, progress: 0.2, input: "This is a input", label: {color: "#ff0000", text: "Hello LayaAir"}};
			
			// //list赋值，先获得一个数据源数组
			// var arr:Array = [];
			// for (var i:int = 0; i < 100; i++) {
			// 	arr.push({label: "item " + i, clip: i % 9});
			// }
			
			// //给list赋值更改list的显示
			// list.array = arr;
		
			//还可以自定义list渲染方式，可以打开下面注释看一下效果
			//list.renderHandler = new Handler(this, onListRender);
		}
		
		private function onListRender(item:Box, index:int):void {
			//自定义list的渲染方式
			// var label:Label = item.getChildByName("label") as Label;
			// if (index % 2) {
			// 	label.color = "#ff0000";
			// } else {
			// 	label.color = "#000000";
			// }
		}
	}
}