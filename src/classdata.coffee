Skills = require './skills'


class WeaponMastery 
  # 武器全般のマスタリ

class DaggerMastery
class SwordMastery
class AxeMastery
class LanceMastery

class TwoHandedMastery
  # 武器攻撃力が増加
  # 武器命中率上昇

class DualWeaponMastery
  # 両手で命中率が落ちない
  # 攻撃速度上昇

class MagicMastery 
  # 魔法全般のマスタリ
  # とくに魔法属性に強く依存

class FireMastery 
class IceMastery 
class ThunderMastery 

class ChainLightning
  # 雷属性 Lord 
  # 高回転+ 長射程 + 低攻撃力
  # Lv5 麻痺延長 or 回避低下
  # Lv10 麻痺延長 or 爆発

class HolySanctuary
  # マップスキル
  # 味方ダメージ上昇 + 敵に聖属性経過ダメージ

class ManaSwap
  # Lord 
  # スイッチ
  # HPダメージをMPに変換
  # Lv5 被ダメージ時HPカウンター or MPカウンター
  # Lv10 低減 or 

class ShockSwap
  # Warrior専用 スイッチ: 永続
  # 打撃ダメージをMagic属性に変換
  # Lv1(0.9,0.1) ... Lv10(0,1.0) Lv15(0,1.5) 

class Survive
  # HP増加
  # バッドコンディション抵抗

class MagicBoost
  # Lord 
  # 武器の魔法効果をブースト

class Vampire 
  # Rogue
  # 武器の吸収効果をブースト
  # lv5 rate上昇 or 素ダメージ上昇
  # lv10 HP吸収->MP変換 or 逆

class ShadowServant
  # 分身を創りだす 範囲攻撃に巻き込まれると死ぬ
  # ターゲット共有
  # DarkMastery で攻撃力+HP上昇

ClassData = 
  Lord : 
    str : 11
    int : 9
    dex : 10
    skills: 
      WeaponMastery: 0
      LanceMastery: 0

      ArmorMastery : 0
      HolyMastery  : 0

      ThunderMastery  : 0
      Lightning: 0 

  Warrior : 
    str : 14
    int : 6
    dex : 9
    skills: 
      WeaponMastery: 1
      SwordMastery : 0
      LanceMastery : 0
      ArmorMastery : 0 

      EarthWave : 0 
      Berserk : 0 
      EnvokeElement : 0

  Rogue : 
    str : 8
    int : 7
    dex : 14
    skills: 
      DaggerMastery: 0
      PoizonMastery: 0
      Tricky: 0

  Sorcerer : 
    str : 5
    int : 15
    dex : 9
    skills: 
      FireMastery   : 0
      FireArrow : 0
      Meteor : 0

      IceMastery    : 0
      ThunderMastery: 0
      Lightning: 0 

      PoizonMastery : 0
      MagicMastery  : 0

class JobClass
class Lord extends JobClass
  constructor:->
    @str = 10
    @int = 10
    @dex = 10 

  toData:->
    str:@str
    int:@int
    dex:@dex
  
class Rogue extends JobClass
  constructor:->
    @str = 7
    @int = 9
    @dex = 14 
    
  toData:->
    str:@str
    int:@int
    dex:@dex

RacialData = 
  human :
    str : 0
    int : 0
    dex : 0
    
  human :
    str : 0
    int : 0
    dex : 0



exports.ClassData = ClassData