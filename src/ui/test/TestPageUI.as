/**Created by the LayaAirIDE,do not modify.*/
package ui.test {
	import laya.ui.*;
	import laya.display.*; 

	public class TestPageUI extends View {
		public var buttonTest:Button;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{"width":600,"height":400},"child":[{"type":"Tab","props":{"y":132,"x":72,"selectedIndex":2},"child":[{"type":"Button","props":{"y":183,"x":184,"width":119,"var":"buttonTest","skin":"template/ButtonTab/btn_LargeTabButton_Left.png","name":"item0","labelSize":36,"labelColors":"#007AFF,#007AFF,#FFFFFF","label":"Button","height":53}}]}]};
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);

		}

	}
}