//
//  AnimationQueue.swift
//  RTS
//
//  Created by Magnus Saurbier on 29.03.24.
//

import Foundation

class AnimationQueue {
    var queue:[Animation] = []
    let game:RTSGame?
    init(game:RTSGame?){
        self.game=game
    }
    func remove(anim:Animation){
        self.queue.removeAll(where: {$0 === anim})
    }
    func update(timeSinceLastUpate:Float){
        if let anim = queue.first{
            anim.update(timeSinceLastUpdate: timeSinceLastUpate)
        }
    }
    func addMovement(to:Vector2, p:Player){
        let anim = PlayerMoveAnimation(boss:self, startPos:p.getFuturePosition(), endPos:to, player:p)
        self.queue.append(anim)
    }
    
}

class Animation {
    let duration:Float //duration in seconds
    let boss:AnimationQueue
    let waitingOn:Animation?
    var isDone:Bool = false
    var t:Float = 0 //progress of the animation
    init(duration:Float = 1.0, boss:AnimationQueue, waitingOn:Animation?=nil){
        self.duration = duration
        self.boss = boss
        self.waitingOn = waitingOn
    }
    func update(timeSinceLastUpdate:Float){
        if let waitingOn = self.waitingOn, !waitingOn.isDone { return }
        self.setState()
        self.t += timeSinceLastUpdate
        if self.t > self.duration{
            self.isDone = true
            self.boss.remove(anim:self)
        }
    }
    ///sets Animation progress according to current t
    func setState(){
        print("not implemented. t=\(t)")
    }
    func setT(_ t:Float=0){
        self.t = t
    }
    func onRelease(){}
}

class PlayerMoveAnimation:Animation {
    let startPos:Vector2
    let endPos:Vector2
    let player:Player
    init(duration:Float = 0.1, boss:AnimationQueue, waitingOn:Animation?=nil, startPos:Vector2, endPos:Vector2, player:Player){
        self.startPos = startPos
        self.endPos = endPos
        self.player = player
        super.init(duration:duration, boss:boss, waitingOn: waitingOn)
    }
    override func setState() {
        let newPos:Vector2 = startPos + self.t/self.duration*(endPos - startPos)
        if newPos != player.getCurrentPosition(){
            self.boss.game?.updateMovement(from:player.getCurrentPosition(), to: newPos, p: player)
            player.displayAt(newPos)
        }
    }
    override func onRelease(){
        player.displayAt(player.getFuturePosition())
    }
}
