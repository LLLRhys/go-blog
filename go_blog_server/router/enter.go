package router

// 包含了所有的路由组
type RouterGroup struct {
	BaseRouter
	UserRouter
	ImageRouter
	ArticleRouter
	CommentRouter
	AdvertisementRouter
	FriendLinkRouter
	FeedbackRouter
	WebsiteRouter
	ConfigRouter
}

var RouterGroupApp = new(RouterGroup)
