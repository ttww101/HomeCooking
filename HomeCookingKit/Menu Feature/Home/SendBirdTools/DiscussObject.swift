import Foundation

class DiscussObject:NSObject {
    var according:DiscussAccordingObject = DiscussAccordingObject()
    var discussId:Int = 0
    var subject:String = ""
    var content:String = ""
    var date:String = ""
    var repostArray:[DiscussRepostObject] = [DiscussRepostObject]()
    var likeArray:[DiscussLikeObject] = [DiscussLikeObject]()
}
