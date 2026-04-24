package service

import (
	"context"
	"errors"
	"server/global"
	"server/model/appTypes"
	"server/model/database"
	"server/model/elasticsearch"
	"server/model/other"
	"server/model/request"
	"server/utils"
	"strconv"
	"time"

	"github.com/elastic/go-elasticsearch/v8/typedapi/core/search"
	"github.com/elastic/go-elasticsearch/v8/typedapi/types"
	"github.com/elastic/go-elasticsearch/v8/typedapi/types/enums/scriptlanguage"
	"github.com/elastic/go-elasticsearch/v8/typedapi/types/enums/sortorder"
	"gorm.io/gorm"
)

type ArticleService struct {
}

func (articleService *ArticleService) ArticleInfoByID(id string) (elasticsearch.Article, error) {
	// 异步更新浏览量
	go func() {
		articleView := articleService.NewArticleView() // 返回 redis 中的键名
		_ = articleView.Set(id)                        // redis中更新浏览量
	}()
	return articleService.Get(id)
}

func (articleService *ArticleService) ArticleSearch(info request.ArticleSearch) (interface{}, int64, error) {
	req := &search.Request{ // 创建一个ES search 请求对象，并且先放一个空的 Query 容器
		Query: &types.Query{},
	}

	boolQuery := &types.BoolQuery{} // 单独创建一个“布尔查询构建器”。它用来逐步收集条件

	// 根据查询字段查询   搜索框里的内容：和文章标题、简介、内容做匹配
	if info.Query != "" {
		boolQuery.Should = []types.Query{ // 创建一个“should”条件，用于匹配多个字段
			{Match: map[string]types.MatchQuery{"title": {Query: info.Query}}},
			{Match: map[string]types.MatchQuery{"keyword": {Query: info.Query}}},
			{Match: map[string]types.MatchQuery{"abstract": {Query: info.Query}}},
			{Match: map[string]types.MatchQuery{"content": {Query: info.Query}}},
		}
	}

	// 根据标签筛选
	if info.Tag != "" {
		boolQuery.Must = []types.Query{ // 创建一个“must”条件
			{Match: map[string]types.MatchQuery{"tags": {Query: info.Tag}}},
		}
	}

	// 根据类别筛选
	if info.Category != "" { // 创建一个过滤条件
		boolQuery.Filter = []types.Query{
			{Term: map[string]types.TermQuery{"category": {Value: info.Category}}},
		}
	}

	// 如果有查询条件，则使用 Bool 查询，否则使用 MatchAll 查询
	if boolQuery.Should != nil || boolQuery.Must != nil || boolQuery.Filter != nil {
		req.Query.Bool = boolQuery
	} else {
		req.Query.MatchAll = &types.MatchAllQuery{}
	}

	// 设置排序字段 | 有排序字段时，先按置顶 和 排序规则排序，最后按照搜索分数排序
	if info.Sort != "" {
		var sortField string
		switch info.Sort {
		case "time":
			sortField = "created_at"
		case "view":
			sortField = "views"
		case "comment":
			sortField = "comments"
		case "like":
			sortField = "likes"
		default:
			sortField = "created_at"
		}

		var order sortorder.SortOrder
		if info.Order != "asc" {
			order = sortorder.Desc
		} else {
			order = sortorder.Asc
		}

		req.Sort = []types.SortCombinations{ // 可以写多个排序字段，顺序就是优先级，越早优先级越高
			types.SortOptions{
				SortOptions: map[string]types.FieldSort{ // SortOptions字段是一个 map，内部无序，所以只能写一个排序字段，不能把多个排序字段写在同一个 SortOptions 中
					"top": {Order: &sortorder.Desc},
				},
			},
			types.SortOptions{
				SortOptions: map[string]types.FieldSort{
					sortField: {Order: &order},
				},
			},
		}
	} else {
		// 没有排序字段时，按照 置顶 和 搜索分数 排序
		req.Sort = []types.SortCombinations{
			types.SortOptions{
				SortOptions: map[string]types.FieldSort{
					"top": {Order: &sortorder.Desc},
				},
			},
		}
	}

	option := other.EsOption{
		PageInfo:       info.PageInfo,
		Index:          elasticsearch.ArticleIndex(),
		Request:        req,
		SourceIncludes: []string{"created_at", "cover", "title", "abstract", "category", "tags", "views", "comments", "likes", "top"},
	}
	return utils.EsPagination(context.TODO(), option)
}

func (articleService *ArticleService) ArticleCategory() ([]database.ArticleCategory, error) {
	var category []database.ArticleCategory
	if err := global.DB.Find(&category).Error; err != nil {
		return nil, err
	}
	return category, nil
}

func (articleService *ArticleService) ArticleTags() ([]database.ArticleTag, error) {
	var tags []database.ArticleTag
	if err := global.DB.Find(&tags).Error; err != nil {
		return nil, err
	}
	return tags, nil
}

func (articleService *ArticleService) ArticleLike(req request.ArticleLike) error {
	return global.DB.Transaction(func(tx *gorm.DB) error {
		var al database.ArticleLike
		var num int

		// 如果用户未收藏，则创建收藏记录
		if errors.Is(tx.Where("user_id = ? AND article_id = ?", req.UserID, req.ArticleID).First(&al).Error, gorm.ErrRecordNotFound) {
			if err := tx.Create(&database.ArticleLike{UserID: req.UserID, ArticleID: req.ArticleID}).Error; err != nil {
				return err
			}
			num = 1
		} else { // 如果用户已经收藏，则取消收藏
			if err := tx.Delete(&al).Error; err != nil {
				return err
			}
			num = -1
		}

		// 更新文章收藏数  构建ES脚本.
		source := "ctx._source.likes += " + strconv.Itoa(num)
		script := types.Script{Source: &source, Lang: &scriptlanguage.Painless}
		_, err := global.ESClient.Update(elasticsearch.ArticleIndex(), req.ArticleID).Script(&script).Do(context.TODO())
		return err
	})
}

func (articleService *ArticleService) ArticleIsLike(req request.ArticleLike) (bool, error) {
	return !errors.Is(global.DB.Where("user_id = ? AND article_id = ?", req.UserID, req.ArticleID).First(&database.ArticleLike{}).Error, gorm.ErrRecordNotFound), nil
}

func (articleService *ArticleService) ArticleLikesList(info request.ArticleLikesList) (interface{}, int64, error) {
	db := global.DB.Where("user_id = ?", info.UserID)
	option := other.MySQLOption{
		PageInfo: info.PageInfo,
		Where:    db,
	}

	l, total, err := utils.MySQLPagination(&database.ArticleLike{}, option)
	if err != nil {
		return nil, 0, err
	}
	var list []struct {
		Id_     string                `json:"_id"`
		Source_ elasticsearch.Article `json:"_source"`
	}

	for _, articleLike := range l {
		article, err := articleService.Get(articleLike.ArticleID) // 通过文章id在ES中查找文章
		if err != nil {
			return nil, 0, err
		}
		article.UpdatedAt = "" // 手动置空，减少返回体积
		article.Keyword = ""
		article.Content = ""
		list = append(list, struct {
			Id_     string                `json:"_id"`
			Source_ elasticsearch.Article `json:"_source"`
		}{
			Id_:     articleLike.ArticleID,
			Source_: article,
		})
	}
	return list, total, nil
}

func (articleService *ArticleService) ArticleCreate(req request.ArticleCreate) error {
	b, err := articleService.Exits(req.Title)
	if err != nil {
		return err
	}
	if b {
		return errors.New("the article already exists")
	}
	now := time.Now().Format("2006-01-02 15:04:05")
	articleToCreate := elasticsearch.Article{
		CreatedAt: now,
		UpdatedAt: now,
		Cover:     req.Cover,
		Title:     req.Title,
		Keyword:   req.Title,
		Category:  req.Category,
		Tags:      req.Tags,
		Abstract:  req.Abstract,
		Content:   req.Content,
		Top:       false,
		TopAt:     now, // ES的date字段只能是只能是 合法日期字符串 或 null，但是string不可以为空，所以先放一个默认值。
	}
	return global.DB.Transaction(func(tx *gorm.DB) error {
		// 同时更新文章类别表中的数据
		if err := articleService.UpdateCategoryCount(tx, "", articleToCreate.Category); err != nil {
			return err
		}

		// 同时更新文章标签表中的数据
		if err := articleService.UpdateTagsCount(tx, []string{}, articleToCreate.Tags); err != nil {
			return err
		}

		// 同时更新图片表中的图片类别
		if err := utils.ChangeImagesCategory(tx, []string{articleToCreate.Cover}, appTypes.Cover); err != nil {
			return err
		}
		illustrations, err := utils.FindIllustrations(articleToCreate.Content)
		if err != nil {
			return err
		}
		if err := utils.ChangeImagesCategory(tx, illustrations, appTypes.Illustration); err != nil {
			return err
		}

		return articleService.Create(&articleToCreate)
	})
}

func (articleService *ArticleService) ArticleDelete(req request.ArticleDelete) error {
	if len(req.IDs) == 0 {
		return nil
	}
	return global.DB.Transaction(func(tx *gorm.DB) error {
		for _, id := range req.IDs {
			articleToDelete, err := articleService.Get(id)
			if err != nil {
				return err
			}

			// 同时更新文章类别表中的数据
			if err := articleService.UpdateCategoryCount(tx, articleToDelete.Category, ""); err != nil {
				return err
			}

			// 同时更新文章标签表中的数据
			if err := articleService.UpdateTagsCount(tx, articleToDelete.Tags, []string{}); err != nil {
				return err
			}

			// 同时更新图片表中的图片类别
			if err := utils.InitImagesCategory(tx, []string{articleToDelete.Cover}); err != nil {
				return err
			}
			illustrations, err := utils.FindIllustrations(articleToDelete.Content)
			if err != nil {
				return err
			}
			if err := utils.InitImagesCategory(tx, illustrations); err != nil {
				return err
			}
			// 同时删除该文章下的所有评论
			comments, err := ServiceGroupApp.CommentService.CommentInfoByArticleID(request.CommentInfoByArticleID{ArticleID: id})
			if err != nil {
				return err
			}
			for _, comment := range comments {
				if err := ServiceGroupApp.CommentService.DeleteCommentAndChildren(tx, comment.ID); err != nil {
					return err
				}
			}
		}
		return articleService.Delete(req.IDs)
	})
}

func (articleService *ArticleService) ArticleUpdate(req request.ArticleUpdate) error {
	now := time.Now().Format("2006-01-02 15:04:05")
	articleToUpdate := struct {
		UpdatedAt string   `json:"updated_at"`
		Cover     string   `json:"cover"`
		Title     string   `json:"title"`
		Keyword   string   `json:"keyword"`
		Category  string   `json:"category"`
		Tags      []string `json:"tags"`
		Abstract  string   `json:"abstract"`
		Content   string   `json:"content"`
	}{
		UpdatedAt: now,
		Cover:     req.Cover,
		Title:     req.Title,
		Keyword:   req.Title,
		Category:  req.Category,
		Tags:      req.Tags,
		Abstract:  req.Abstract,
		Content:   req.Content,
	}
	return global.DB.Transaction(func(tx *gorm.DB) error {
		oldArticle, err := articleService.Get(req.ID)
		if err != nil {
			return err
		}

		// 同时更新文章类别表中的数据
		if err := articleService.UpdateCategoryCount(tx, oldArticle.Category, articleToUpdate.Category); err != nil {
			return err
		}

		// 同时更新文章标签表中的数据
		if err := articleService.UpdateTagsCount(tx, oldArticle.Tags, articleToUpdate.Tags); err != nil {
			return err
		}

		// 同时更新图片表中的图片类别
		if articleToUpdate.Cover != oldArticle.Cover {
			if err := utils.InitImagesCategory(tx, []string{oldArticle.Cover}); err != nil {
				return err
			}
			if err := utils.ChangeImagesCategory(tx, []string{articleToUpdate.Cover}, appTypes.Cover); err != nil {
				return err
			}
		}
		oldIllustrations, err := utils.FindIllustrations(oldArticle.Content)
		if err != nil {
			return err
		}
		newIllustrations, err := utils.FindIllustrations(articleToUpdate.Content)
		if err != nil {
			return err
		}
		addedIllustrations, removedIllustrations := utils.DiffArrays(oldIllustrations, newIllustrations)
		if err := utils.InitImagesCategory(tx, removedIllustrations); err != nil {
			return err
		}
		if err := utils.ChangeImagesCategory(tx, addedIllustrations, appTypes.Illustration); err != nil {
			return err
		}

		return articleService.Update(req.ID, articleToUpdate)
	})
}

func (articleService *ArticleService) ArticleList(info request.ArticleList) (list interface{}, total int64, err error) {
	req := &search.Request{ // 创建一个ES search 请求对象，并且先放一个空的 Query 容器
		Query: &types.Query{},
	}

	boolQuery := &types.BoolQuery{} //  单独创建一个“布尔查询构建器”。它用来逐步收集条件

	// 根据标题查询
	if info.Title != nil {
		// 向 boolQuery 添加一个 must 条件
		// types.Query{Match:} 添加一个 match 查询：在ES字段 title 上匹配 info.Title 的值
		boolQuery.Must = append(boolQuery.Must, types.Query{Match: map[string]types.MatchQuery{"title": {Query: *info.Title}}})
	}

	// 根据简介查询
	if info.Abstract != nil {
		boolQuery.Must = append(boolQuery.Must, types.Query{Match: map[string]types.MatchQuery{"abstract": {Query: *info.Abstract}}})
	}

	// 根据类别筛选 只返回 category 字段等于传入值的文章
	if info.Category != nil {
		boolQuery.Filter = []types.Query{ // boolQuery 中添加一个过滤条件 filter，
			{
				Term: map[string]types.TermQuery{ // term 是精准匹配
					"category": {Value: info.Category},
				},
			},
		}
	}

	// 根据条件执行查询
	if boolQuery.Must != nil || boolQuery.Filter != nil {
		req.Query.Bool = boolQuery // 把查询构建器 boolQuery 放进 req ES查询对象中
	} else {
		req.Query.MatchAll = &types.MatchAllQuery{} // 查询所有
	}

	// ！types.SortOptions.SortOptions 是一个 map，golang中的 map 是无序的，所以多个排序规则不能写在同一个排序项中
	req.Sort = []types.SortCombinations{ // []types.SortCombinations 排序项的“组合类型”, 排序项的顺序就是优先级，越早优先级越高
		types.SortOptions{ // 一个排序项
			SortOptions: map[string]types.FieldSort{ // 键是字段名，值是字段的排序规则
				"top": {Order: &sortorder.Desc},
			},
		},
		types.SortOptions{ // 第二个排序项
			SortOptions: map[string]types.FieldSort{
				"created_at": {Order: &sortorder.Desc},
			},
		},
	}

	option := other.EsOption{
		PageInfo: info.PageInfo,
		Index:    elasticsearch.ArticleIndex(),
		Request:  req,
	}
	return utils.EsPagination(context.TODO(), option) // context.TODO() 创建一个空的 context , 未来可以拓展（加超时时间之类的）
}

func (articleService *ArticleService) ArticleTop(req request.ArticleTop) error {
	now := time.Now().Format("2006-01-02 15:04:05")

	// 有逻辑运算，用ES脚本方便些
	source := "ctx._source.top = !ctx._source.top; ctx._source.top_at = '" + now + "'"
	script := types.Script{Source: &source, Lang: &scriptlanguage.Painless}
	_, err := global.ESClient.Update(elasticsearch.ArticleIndex(), req.ArticleID).Script(&script).Do(context.TODO())
	return err
}
