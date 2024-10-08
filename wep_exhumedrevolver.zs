// ------------------------------------------------------------
// Powerslave Revolver
// ------------------------------------------------------------
class HDExhuRev:HDHandgun{
	bool cylinderopen; //don't use weaponstatus since it shouldn't be saved anyway
	default{
		+hdweapon.fitsinbackpack
		+hdweapon.reverseguninertia
		scale 0.45;
		weapon.selectionorder 49;
		weapon.slotnumber 2;
		weapon.slotpriority 3;
		weapon.kickback 32;
		weapon.bobrangex 0.11;
		weapon.bobrangey 0.61;
		weapon.bobspeed 2.5;
		weapon.bobstyle "normal";
		obituary "$OB_REVOLVER";
		inventory.pickupmessage "Dusted off an old revolver";
		tag "N.W.M.P. Webley Commonwealth";
		hdweapon.refid "web";
		hdweapon.barrelsize 19,0.3,0.5; //mildly longer than the 355

		hdweapon.ammo1 "HD45ACPAmmo",6;
	}
	override double gunmass(){
		double blk=0;
		for(int i=BUGS_CYL1;i<=BUGS_CYL6;i++){
			int wi=weaponstatus[i];
			if(wi==BUGS_MASTERBALL)blk+=0.12;
			else if(wi==BUGS_NINEMIL)blk+=0.1;
		}
		return blk+4;
	}
	override double weaponbulk(){
		double blk=0;
		for(int i=BUGS_CYL1;i<=BUGS_CYL6;i++){
			int wi=weaponstatus[i];
			if(wi==BUGS_MASTERBALL)blk+=ENC_355_LOADED;
			else if(wi==BUGS_NINEMIL)blk+=ENC_9_LOADED;
		}
		return blk+32;
	}
	override string,double getpickupsprite(){
		return "EXHUM0",1.;
	}

	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawimage("45RNA0",(-47,-10),sb.DI_SCREEN_CENTER_BOTTOM,scale:(2.25,2.55));
			sb.drawnum(hpl.countinv("HD45ACPAmmo"),-44,-8,sb.DI_SCREEN_CENTER_BOTTOM);
			int ninemil=hpl.countinv("HD45ACPAmmo");
			if(ninemil>0){
				sb.drawimage("45RNA0",(-47,-10),sb.DI_SCREEN_CENTER_BOTTOM,scale:(2.1,2.1));
				sb.drawnum(ninemil,-44,-8,sb.DI_SCREEN_CENTER_BOTTOM);
			}
		}
		int plf=hpl.player.getpsprite(PSP_WEAPON).frame;
		for(int i=BUGS_CYL1;i<=BUGS_CYL6;i++){
			double drawangle=i*(360./6.)-150;
			vector2 cylpos;
			if(plf==4){
				drawangle-=45.;
				cylpos=(-30,-14);
			}else if(cylinderopen){
				drawangle-=90;
				cylpos=(-34,-12);
			}else{
				cylpos=(-22,-20);
			}
			double cdrngl=cos(drawangle);
			double sdrngl=sin(drawangle);
			if(
				!cylinderopen
				&&sb.hud_aspectscale.getbool()
			){
				cdrngl*=1.1;
				sdrngl*=(1./1.1);
			}
			vector2 drawpos=cylpos+(cdrngl,sdrngl)*5;
			sb.fill(
				hdw.weaponstatus[i]>0?
				color(255,240,230,40)
				:color(200,30,26,24),
				drawpos.x,
				drawpos.y,
				3,3,
				sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_RIGHT
			);
		}
	}
	override string gethelptext(){
		LocalizeHelp();
		if(cylinderopen)return
		LWPHELP_FIRE
		..StringTable.Localize("$REVCWH_FIRE")//" Close cylinder\n"
		..LWPHELP_ALTFIRE..StringTable.Localize("$REVCWH_ALTFIRE")..LWPHELP_ZOOM..StringTable.Localize("$REVCWH_ALTZOOM")
		..WEPHELP_UNLOAD.." Remove empty rounds \(double-tap to spin the gun\)\n"
		..LWPHELP_RELOAD..StringTable.Localize(" Load round")
		;
		return
		LWPHELP_FIRESHOOT
		..LWPHELP_ALTFIRE..StringTable.Localize("$REVWH_ALTFIRE")
		..LWPHELP_ALTRELOAD.."/"..LWPHELP_FIREMODE..StringTable.Localize("$REVWH_ARELOADPFMOD")
		..LWPHELP_UNLOAD.."/"..LWPHELP_RELOAD..StringTable.Localize("$REVWH_RELOAD")
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		if(HDExhuRev(hdw).cylinderopen)return;

		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		vector2 scc;
		vector2 bobb=bob*1.3;

		sb.SetClipRect(
			-8+bob.x,-9+bob.y,16,15,
			sb.DI_SCREEN_CENTER
		);
		scc=(0.9,0.9);

		sb.drawimage(
			"exhfst",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9,scale:scc
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"exhbkst",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			scale:scc
		);
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,18,60);
			if(owner.countinv("HD45ACPAmmo"))owner.A_DropInventory("HD45ACPAmmo",amt);
			else owner.A_DropInventory("HD45ACPAmmo",amt);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_SetInventory("HD45ACPAmmo",1);
	}
	override void initializewepstats(bool idfa){
		weaponstatus[BUGS_CYL1]=BUGS_MASTERBALL;
		weaponstatus[BUGS_CYL2]=BUGS_MASTERBALL;
		weaponstatus[BUGS_CYL3]=BUGS_MASTERBALL;
		weaponstatus[BUGS_CYL4]=BUGS_MASTERBALL;
		weaponstatus[BUGS_CYL5]=BUGS_MASTERBALL;
		weaponstatus[BUGS_CYL6]=BUGS_MASTERBALL;
	}

	action bool HoldingRightHanded(){
		bool righthanded=invoker.wronghand;
		righthanded=
		(
			righthanded
			&&Wads.CheckNumForName("id",0)!=-1
		)||(
			!righthanded
			&&Wads.CheckNumForName("id",0)==-1
		);
		return righthanded;
	}
	action void A_CheckRevolverHand(){
		bool righthanded=HoldingRightHanded();
		if(righthanded)player.getpsprite(PSP_WEAPON).sprite=getspriteindex("EEHGA0");
		else player.getpsprite(PSP_WEAPON).sprite=getspriteindex("EXHGA0");
	}
	action void A_RotateCylinder(bool clockwise=true){
		invoker.RotateCylinder(clockwise);
		A_StartSound("weapons/deinocyl",8);
	}
	void RotateCylinder(bool clockwise=true){
		if(clockwise){
			int cylbak=weaponstatus[BUGS_CYL1];
			weaponstatus[BUGS_CYL1]=weaponstatus[BUGS_CYL6];
			weaponstatus[BUGS_CYL6]=weaponstatus[BUGS_CYL5];
			weaponstatus[BUGS_CYL5]=weaponstatus[BUGS_CYL4];
			weaponstatus[BUGS_CYL4]=weaponstatus[BUGS_CYL3];
			weaponstatus[BUGS_CYL3]=weaponstatus[BUGS_CYL2];
			weaponstatus[BUGS_CYL2]=cylbak;
		}else{
			int cylbak=weaponstatus[BUGS_CYL1];
			weaponstatus[BUGS_CYL1]=weaponstatus[BUGS_CYL2];
			weaponstatus[BUGS_CYL2]=weaponstatus[BUGS_CYL3];
			weaponstatus[BUGS_CYL3]=weaponstatus[BUGS_CYL4];
			weaponstatus[BUGS_CYL4]=weaponstatus[BUGS_CYL5];
			weaponstatus[BUGS_CYL5]=weaponstatus[BUGS_CYL6];
			weaponstatus[BUGS_CYL6]=cylbak;
		}
	}
	action void A_LoadRound(){
		if(invoker.weaponstatus[BUGS_CYL1]>0)return;
		bool useninemil=(
			player.cmd.buttons&BT_FIREMODE
			||!countinv("HD45ACPAmmo")
		);
		if(useninemil&&!countinv("HD45ACPAmmo"))return;
		class<inventory>ammotype=useninemil?"HD45ACPAmmo":"HD45ACPAmmo";
		A_TakeInventory(ammotype,1,TIF_NOTAKEINFINITE);
		invoker.weaponstatus[BUGS_CYL1]=useninemil?BUGS_NINEMIL:BUGS_MASTERBALL;
		A_StartSound("weapons/deinoload",8,CHANF_OVERLAP);
	}
	action void A_OpenCylinder(){
		A_StartSound("weapons/rifleclick",8);
		invoker.weaponstatus[0]&=~BUGF_COCKED;
		invoker.cylinderopen=true;
		A_SetHelpText();
	}
	action void A_CloseCylinder(){
		A_StartSound("weapons/rifleclick",8);
		invoker.cylinderopen=false;
		A_SetHelpText();
	}
	action void A_HitExtractor(){
		double cosp=cos(pitch);
		for(int i=BUGS_CYL1;i<=BUGS_CYL6;i++){
			int thischamber=invoker.weaponstatus[i];
			if(thischamber<1)continue;
			if(
				thischamber==BUGS_NINEMILSPENT
				||thischamber==BUGS_NINEMIL
				||thischamber==BUGS_MASTERBALLSPENT
				||thischamber==BUGS_MASTERBALL
			){
				actor aaa=spawn(
					thischamber==BUGS_NINEMIL?"HD45ACPAmmo"
						:thischamber==BUGS_MASTERBALLSPENT?"HDSpent45ACP"
						:thischamber==BUGS_MASTERBALL?"HD45ACPAmmo"
						:"HDSpent45ACP",
					(pos.xy,pos.z+height-10)
					+(cosp*cos(angle),cosp*sin(angle),sin(pitch))*7,
					ALLOW_REPLACE
				);
				aaa.vel=vel+(frandom(-1,1),frandom(-1,1),-1);
				aaa.angle=angle;
				invoker.weaponstatus[i]=0;
			}
		}
		A_StartSound("weapons/deinoeject",8,CHANF_OVERLAP);
	}
	action void A_ExtractAll(){
		double cosp=cos(pitch);
		bool gotany=false;
		for(int i=BUGS_CYL1;i<=BUGS_CYL6;i++){
			int thischamber=invoker.weaponstatus[i];
			if(thischamber<1)continue;
			if(
				thischamber==BUGS_NINEMILSPENT
				||thischamber==BUGS_MASTERBALLSPENT
			){
				actor aaa=spawn("HDSpent45ACP",
					(pos.xy,pos.z+height-14)
					+(cosp*cos(angle),cosp*sin(angle),sin(pitch)-2)*3,
					ALLOW_REPLACE
				);
				aaa.vel=vel+(frandom(-0.3,0.3),frandom(-0.3,0.3),-1);
				if(thischamber==BUGS_MASTERBALLSPENT)aaa.scale.y=0.85;
				invoker.weaponstatus[i]=0;
			}else{
				//give or spawn either 9mm or 355
				class<inventory>ammotype=
					thischamber==BUGS_MASTERBALL?
					"HD45ACPAmmo":"HD45ACPAmmo";
				if(A_JumpIfInventory(ammotype,0,"null")){
					actor aaa=spawn(ammotype,
						(pos.xy,pos.z+height-14)
						+(cosp*cos(angle),cosp*sin(angle),sin(pitch)-2)*3,
						ALLOW_REPLACE
					);
					aaa.vel=vel+(frandom(-1,1),frandom(-1,1),-1);
				}else{
					A_GiveInventory(ammotype,1);
					gotany=true;
				}
				invoker.weaponstatus[i]=0;
			}
		}
		if(gotany)A_StartSound("weapons/pocket",9);
	}
	action void A_FireRevolver(){
		invoker.weaponstatus[0]&=~BUGF_COCKED;
		int cyl=invoker.weaponstatus[BUGS_CYL1];
		if(
			cyl!=BUGS_MASTERBALL
			&&cyl!=BUGS_NINEMIL
		){
			A_StartSound("weapons/deinoclick",8,CHANF_OVERLAP);
			return;
		}
		invoker.weaponstatus[BUGS_CYL1]--;
		bool godscaliber=cyl==BUGS_MASTERBALL;

		let bbb=HDBulletActor.FireBullet(self,godscaliber?"HDB_45ACP":"HDB_45ACP",spread:1.,speedfactor:frandom(1.05,1.06));
		if(
			frandom(0,ceilingz-floorz)<bbb.speed*(godscaliber?0.4:0.3)
		)A_AlertMonsters(godscaliber?512:256);

		A_GunFlash();
		A_Light1();
		A_ZoomRecoil(1);
		HDFlashAlpha(godscaliber?72:64);
		A_StartSound("weapons/exhumedshoot",CHAN_WEAPON,CHANF_OVERLAP);
		if(hdplayerpawn(self)){
			hdplayerpawn(self).gunbraced=false;
		}
		if(godscaliber){
			A_MuzzleClimb(-frandom(0.8,1.6),-frandom(2.2,2.4));
			A_StartSound("weapons/exhblast",CHAN_WEAPON,CHANF_OVERLAP,20);
			A_StartSound("weapons/deinoblast1",CHAN_WEAPON,CHANF_OVERLAP,1.9);
			A_StartSound("weapons/deinoblast2",CHAN_WEAPON,CHANF_OVERLAP,1.9);
		}else{
			A_MuzzleClimb(-frandom(0.6,1.2),-frandom(2.2,2.4));
			A_StartSound("weapons/exhblast",CHAN_WEAPON,CHANF_OVERLAP,20);
			A_StartSound("weapons/deinoblast1",CHAN_WEAPON,CHANF_OVERLAP,1.9);
			A_StartSound("weapons/deinoblast2",CHAN_WEAPON,CHANF_OVERLAP,1.9);
		}
	}
	int cooldown;
	action void A_ReadyOpen(){
		A_WeaponReady(WRF_NOFIRE|WRF_ALLOWUSER3);
		if(justpressed(BT_ALTATTACK))setweaponstate("open_rotatecylinder");
		else if(justpressed(BT_RELOAD)){
			if(
				(
					invoker.weaponstatus[BUGS_CYL1]>0
					&&invoker.weaponstatus[BUGS_CYL2]>0
					&&invoker.weaponstatus[BUGS_CYL3]>0
					&&invoker.weaponstatus[BUGS_CYL4]>0
					&&invoker.weaponstatus[BUGS_CYL5]>0
					&&invoker.weaponstatus[BUGS_CYL6]>0
				)||(
					!countinv("HD45ACPAmmo")
					&&!countinv("HD45ACPAmmo")
				)
			)setweaponstate("open_closecylinder");
			else setweaponstate("open_loadround");
		}else if(justpressed(BT_ATTACK))setweaponstate("open_closecylinder");
		else if(justpressed(BT_UNLOAD)){
			if(!invoker.cooldown){
				setweaponstate("open_dumpcylinder");
				invoker.cooldown=6;
			}else{
				setweaponstate("open_dumpcylinder_all");
			}
		}
		if(invoker.cooldown>0)invoker.cooldown--;
	}
	action void A_RoundReady(int rndnm){
		int gunframe=-1;
		if(invoker.weaponstatus[rndnm]>0)gunframe=player.getpsprite(PSP_WEAPON).frame;
		let thissprite=player.getpsprite(BUGS_OVRCYL+rndnm);
		switch(gunframe){
		case 4: //E
			thissprite.frame=0;
			break;
		case 5: //F
			thissprite.frame=1;
			break;
		case 6: //G
			thissprite.frame=pressingzoom()?4:2;
			break;
		default:
			thissprite.sprite=getspriteindex("TNT1A0");
			thissprite.frame=0;
			return;break;
		}
	}
	action void A_CockHammer(bool yes=true){
		if(yes)invoker.weaponstatus[0]|=BUGF_COCKED;
		else invoker.weaponstatus[0]&=~BUGF_COCKED;
	}


/*
	A normal ready
	B ready cylinder midframe
	C hammer fully cocked (maybe renumber these lol)
	D recoil frame
	E cylinder swinging out - left hand passing to right
	F cylinder swung out - held in right hand, working chamber in middle
	G cylinder swung out midframe
*/
	states{
	spawn:
		EXHU M -1;
		stop;
	round1:EHE1 A 1 A_RoundReady(BUGS_CYL1);wait;
	round2:EHE2 A 1 A_RoundReady(BUGS_CYL2);wait;
	round3:EHE3 A 1 A_RoundReady(BUGS_CYL3);wait;
	round4:EHE4 A 1 A_RoundReady(BUGS_CYL4);wait;
	round5:EHE5 A 1 A_RoundReady(BUGS_CYL5);wait;
	round6:EHE6 A 1 A_RoundReady(BUGS_CYL6);wait;
	select0:
		EXHG A 0{
			if(!countinv("NulledWeapon"))invoker.wronghand=false;
			A_TakeInventory("NulledWeapon");
			A_CheckRevolverHand();
			invoker.cylinderopen=false;
			invoker.weaponstatus[0]&=~BUGF_COCKED;

			//uncock all spare revolvers
			if(findinventory("SpareWeapons")){
				let spw=SpareWeapons(findinventory("SpareWeapons"));
				for(int i=0;i<spw.weapontype.size();i++){
					if(spw.weapontype[i]==invoker.getclassname()){
						string spw2=spw.weaponstatus[i];
						string spw1=spw2.left(spw2.indexof(","));
						spw2=spw2.mid(spw2.indexof(","));
						int stat0=spw1.toint();
						stat0&=~BUGF_COCKED;
						spw.weaponstatus[i]=stat0..spw2;
					}
				}
			}

			A_Overlay(BUGS_OVRCYL+BUGS_CYL1,"round1");
			A_Overlay(BUGS_OVRCYL+BUGS_CYL2,"round2");
			A_Overlay(BUGS_OVRCYL+BUGS_CYL3,"round3");
			A_Overlay(BUGS_OVRCYL+BUGS_CYL4,"round4");
			A_Overlay(BUGS_OVRCYL+BUGS_CYL5,"round5");
			A_Overlay(BUGS_OVRCYL+BUGS_CYL6,"round6");
		}
		---- A 1 A_Raise();
		---- A 1 A_Raise(40);
		---- A 1 A_Raise(40);
		---- A 1 A_Raise(25);
		---- A 1 A_Raise(20);
		wait;
	deselect0:
		EXHG A 0 A_CheckRevolverHand();
		#### D 0 A_JumpIf(!invoker.cylinderopen,"deselect0a");
		EXHG F 1 A_CloseCylinder();
		EXHG E 1;
		EXHG A 0 A_CheckRevolverHand();
		goto deselect0a;
	deselect0a:
		#### AD 1 A_Lower();
		---- A 1 A_Lower(20);
		---- A 1 A_Lower(34);
		---- A 1 A_Lower(50);
		wait;
	ready:
		EXHG A 0 A_CheckRevolverHand();
		---- A 0 A_JumpIf(invoker.cylinderopen,"readyopen");
		#### C 0 A_JumpIf(invoker.weaponstatus[0]&BUGF_COCKED,2);
		#### A 0;
		---- A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1|WRF_ALLOWUSER2|WRF_ALLOWUSER3|WRF_ALLOWUSER4);
		goto readyend;
	fire:
		#### A 0 A_JumpIf(invoker.weaponstatus[0]&BUGF_COCKED,"hammertime");
		#### B 1 offset(0,34);
		#### C 2 offset(0,36) A_RotateCylinder();
		#### A 0 offset(0,32);
	hammertime:
		#### A 0 A_ClearRefire();
		#### A 1 A_FireRevolver();
		goto nope;
	firerecoil:
		#### D 2;
		#### A 0;
		goto nope;
	flash:
		EXHF A 1 bright;
		---- A 0 A_Light0();
		---- A 0 setweaponstate("firerecoil");
		stop;
		EEHG ABCD 0;
		stop;
	altfire:
		---- A 0 A_JumpIf(invoker.weaponstatus[0]&BUGF_COCKED,"uncock");
		#### B 1 offset(0,33) A_ClearRefire();
		#### B 2 offset(0,34) A_RotateCylinder();
	cocked:
		#### C 0 A_CockHammer();
		---- A 0 A_JumpIf(pressingaltfire(),"nope");
		goto readyend;
	uncock:
		#### C 1 offset(0,36);
		#### B 1 offset(0,32);
		#### A 2 offset(0,34) A_StartSound("weapons/deinocyl",8,CHANF_OVERLAP);
		#### A 0 A_CockHammer(false);
		goto nope;
	reload:
	unload:
		#### C 0 A_JumpIf(!(invoker.weaponstatus[0]&BUGF_COCKED),3);
		#### B 2 offset(0,35)A_CockHammer(false);
		#### A 2 offset(0,33);
		#### A 1 A_JumpIf(player.getpsprite(PSP_WEAPON).sprite!=getspriteindex("EEHGA0"),"openslow");
		#### A 1 A_JumpIf(player.getpsprite(PSP_WEAPON).sprite!=getspriteindex("EXHGA0"),"openslow");
		EXHG E 2 A_OpenCylinder();
		goto readyopen;
	openslow:
		EXHG E 1;
		EXHG E 1 A_OpenCylinder();
		EXHG F 3 A_HitExtractor();
		goto readyopen;
	readyopen:
		EXHG F 1 A_ReadyOpen();
		goto readyend;
	open_rotatecylinder:
		EXHG G 2 A_RotateCylinder(pressingzoom());
		EXHG F 2 A_JumpIf(!pressingaltfire(),"readyopen");
		loop;
	open_loadround:
		EXHG F 2;
		EXHG F 1 A_LoadRound();
		goto open_rotatecylinder;
	open_closecylinder:
		EXHG E 2 A_JumpIf(pressingfire(),"open_fastclose");
		EXHG E 0 A_CloseCylinder();
		EXHG A 0 A_CheckRevolverHand();
		#### A 0 A_JumpIf(player.getpsprite(PSP_WEAPON).sprite==getspriteindex("EEHGA0"),"nope");
		#### A 0 A_JumpIf(player.getpsprite(PSP_WEAPON).sprite==getspriteindex("EXHGA0"),"nope");
		EXHG E 1 offset(0,32);
		EXHG E 1 offset(-2,40);
		EXHG E 1 offset(-6,56);
		EXHG E 1 offset(-7,66);
		EXHG A 1 offset(12,96);
		EXHG A 1 offset(10,86);
		EXHG A 2 offset(8,64);
		EXHG A 2 offset(4,50);
		EXHG A 2 offset(2,39);
		goto nope;
	open_fastclose:
		EXHG E 2;
		EXHG A 0{
			A_CloseCylinder();
			invoker.wronghand=(Wads.CheckNumForName("id",0)!=-1);
			A_CheckRevolverHand();
		}goto nope;
	open_dumpcylinder:
		EXHG F 3 A_HitExtractor();
		goto readyopen;
	open_dumpcylinder_all:
		EXHG F 1 offset(0,34);
		EXHG F 1 offset(0,42);
		EXHG F 1 offset(0,54);
		EXHG F 1 offset(0,68);
		EXHG F 1 offset(0,68) A_StartSound("weapons/exhspin",8);
		TNT1 A 6 A_ExtractAll();
		EXHG F 1 offset(0,68) A_StartSound("weapons/deinocyl",8);
		EXHG G 1 offset(0,63) A_StartSound("weapons/deinocyl",8);
		EXHG F 1 offset(0,59) A_StartSound("weapons/deinocyl",8);
		EXHG G 1 offset(0,54) A_StartSound("weapons/deinocyl",8);
		EXHG F 1 offset(0,50) A_StartSound("weapons/deinocyl",8);
		EXHG G 2 offset(0,46) A_StartSound("weapons/deinocyl",8);
		EXHG F 2 offset(0,42) A_StartSound("weapons/deinocyl",8);
		EXHG G 2 offset(0,40) A_StartSound("weapons/deinocyl",8);
		EXHG F 2 offset(0,38) A_StartSound("weapons/deinocyl",8);
		EXHG G 2 offset(0,36) A_StartSound("weapons/deinocyl",8);
		EXHG F 2 offset(0,34) A_StartSound("weapons/deinocyl",8);
		goto readyopen;

	user1:
	user2:
	swappistols:
		---- A 0 A_SwapHandguns();
		#### D 0 A_JumpIf(player.getpsprite(PSP_WEAPON).sprite==getspriteindex("EEHGA0"),"swappistols2");
	swappistols1:
		TNT1 A 0 A_Overlay(1025,"raiseright");
		TNT1 A 0 A_Overlay(1026,"lowerleft");
		TNT1 A 5;
		EEHG C 0 A_JumpIf(invoker.weaponstatus[0]&BUGF_COCKED,"nope");
		EEHG A 0;
		goto nope;
	swappistols2:
		TNT1 A 0 A_Overlay(1025,"raiseleft");
		TNT1 A 0 A_Overlay(1026,"lowerright");
		TNT1 A 5;
		EXHG C 0 A_JumpIf(invoker.weaponstatus[0]&BUGF_COCKED,"nope");
		EXHG A 0;
		goto nope;
	lowerleft:
		EXHG C 0 A_JumpIf(invoker.weaponstatus[0]&BUGF_COCKED,2);
		EXHG A 0;
		---- A 1 offset(-6,38);
		---- A 1 offset(-12,48);
		EXHG D 1 offset(-20,60);
		EXHG D 1 offset(-34,76);
		EXHG D 1 offset(-50,86);
		stop;
	lowerright:
		EEHG C 0 A_JumpIf(invoker.weaponstatus[0]&BUGF_COCKED,2);
		EEHG A 0;
		---- A 1 offset(6,38);
		---- A 1 offset(12,48);
		EEHG D 1 offset(20,60);
		EEHG D 1 offset(34,76);
		EEHG D 1 offset(50,86);
		stop;
	raiseleft:
		EXHG D 1 offset(-50,86);
		EXHG D 1 offset(-34,76);
		EXHG C 0 A_JumpIf(invoker.weaponstatus[0]&BUGF_COCKED,2);
		EXHG A 0;
		---- A 1 offset(-20,60);
		---- A 1 offset(-12,48);
		---- A 1 offset(-6,38);
		stop;
	raiseright:
		EXHG D 1 offset(50,86);
		EXHG D 1 offset(34,76);
		EXHG C 0 A_JumpIf(invoker.weaponstatus[0]&BUGF_COCKED,2);
		EXHG A 0;
		---- A 1 offset(20,60);
		---- A 1 offset(12,48);
		---- A 1 offset(6,38);
		stop;
	whyareyousmiling:
		#### D 1 offset(0,38);
		#### D 1 offset(0,48);
		#### D 1 offset(0,60);
		TNT1 A 7;
		EXHG A 0{
			invoker.wronghand=!invoker.wronghand;
			A_CheckRevolverHand();
		}
		#### D 1 offset(0,60);
		#### D 1 offset(0,48);
		#### D 1 offset(0,38);
		goto nope;
	}
}
enum DeinovolverStats{
	//chamber 1 is the shooty one
	BUGS_CYL1=1,
	BUGS_CYL2=2,
	BUGS_CYL3=3,
	BUGS_CYL4=4,
	BUGS_CYL5=5,
	BUGS_CYL6=6,
	BUGS_OVRCYL=355,

	//odd means spent
	BUGS_NINEMILSPENT=1,
	BUGS_NINEMIL=2,
	BUGS_MASTERBALLSPENT=3,
	BUGS_MASTERBALL=4,

	BUGF_RIGHTHANDED=1,
	BUGF_COCKED=2,
}
