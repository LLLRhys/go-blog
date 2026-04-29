<template>
  <section class="article-list">
    <div class="header">
      <h2 class="title">最新文章</h2>
      <el-link type="primary" :underline="false" @click="goSearchPage">查看全部 →</el-link>
    </div>

    <el-table class="article-table" :data="articleCards" :show-header="false" :row-style="{height: '200px'}">
      <el-table-column label="cover" width="200">
        <template #default="scope:{ row: Hit<Article>, column: any, $index: number }">
          <el-image class="cover" :src="scope.row._source.cover" fit="cover" alt=""/>
        </template>
      </el-table-column>
      <el-table-column label="description">
        <template #default="scope:{ row: Hit<Article>, column: any, $index: number }">
          <div class="description" @click="handleArticleJumps(scope.row._id)">
            <el-row class="article-title">
              {{ scope.row._source.title }}
              <el-tag
                v-if="scope.row._source.top"
                class="top-tag"
                type="danger"
                size="small"
                effect="dark"
                style="margin-left:8px;vertical-align:middle;"
              >置顶</el-tag>
            </el-row>
            <el-text class="abstract" size="large">{{ scope.row._source.abstract }}</el-text>
            <el-text class="footer">
              <div class="tags">
                <el-tag v-for="tag in scope.row._source.tags.slice(0, 5)" :key="tag">{{ tag }}</el-tag>
              </div>
              <div class="status">
                发布时间：{{ formatDate(scope.row._source.created_at) }}
                <el-icon>
                  <component is="View"/>
                </el-icon>
                {{ scope.row._source.views }}
                <el-icon>
                  <component is="ChatDotRound"/>
                </el-icon>
                {{ scope.row._source.comments }}
                <el-icon>
                  <component is="Star"/>
                </el-icon>
                {{ scope.row._source.likes }}
              </div>
            </el-text>
          </div>
        </template>
      </el-table-column>
    </el-table>

  </section>
</template>

<script setup lang="ts">
import type {Hit} from "@/api/common";
import {type Article, articleSearch, type ArticleSearchRequest} from "@/api/article";
import {reactive, ref} from "vue";
import {useRouter} from "vue-router";

const router = useRouter()

const articleSearchRequest = reactive<ArticleSearchRequest>({
  query: "",
  category: "",
  tag: "",
  sort: "time",
  order: "desc",
  page: 1,
  page_size: 6,
})

const articleCards = ref<Hit<Article>[]>([])

const getArticleList = async () => {
  articleSearchRequest.page = 1
  articleSearchRequest.page_size = 6
  const res = await articleSearch(articleSearchRequest)
  if (res.code === 0) {
    articleCards.value = res.data.list
  }
}

getArticleList()

const handleArticleJumps = (id: string) => {
  window.open("/article/" + id)
}

const goSearchPage = () => {
  router.push({name: "search"})
}

const formatDate = (date: string) => {
  if (!date) return ""
  return date.split(" ")[0]
}
</script>

<style scoped lang="scss">
.article-list {
  border-radius: 18px;
  background: #f7f8fb;
  border: 1px solid #dfe3ea;
  color: #5f6b7a;
  padding: 28px 22px 18px;

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;

    .title {
      margin: 0;
      font-size: 24px;
      font-weight: 700;
      color: #3f4958;
    }
  }

  .article-table {
    background: transparent;

    .cover {
      width: 400px;
      height: 280px;
      border-radius: 0;
    }

    .top-tag {
      margin-left: 8px;
      font-size: 13px;
      font-weight: bold;
      letter-spacing: 1px;
      background: linear-gradient(90deg, #ff4d4f 60%, #ff7875 100%);
      color: #fff !important;
      border: none;
      border-radius: 4px;
      padding: 0 8px;
      vertical-align: middle;
      box-shadow: 0 1px 4px rgba(255,77,79,0.08);
    }

    :deep(.el-table__inner-wrapper::before) {
      background: transparent;
    }

    :deep(.el-table__row) {
      cursor: pointer;
      transition: background-color 0.2s ease;
    }

    :deep(.el-table__row td) {
      background: #f2f4f8;
      border-bottom: 1px solid #e7ebf1;
      color: #5b6676;
    }

    :deep(.el-table__row:hover td) {
      background: #edf1f7;
    }

    .description {
      height: 160px;
      display: flex;
      flex-direction: column;

      .article-title {
        font-size: 24px;
        margin-bottom: 10px;
        color: #525f71;
      }

      .abstract {
        margin-right: auto;
        color: #677489;
        font-size: 20px;
      }

      .footer {
        margin-top: auto;
        display: flex;
        width: 100%;

        .tags {
          margin-right: auto;

          .el-tag {
            margin-right: 10px;
            font-size: 15px;
            padding: 6px 12px;
          }
        }

        .status {
          margin-left: auto;
          color: #6a7689;
          font-size: 14px;
        }
      }
    }
  }

  @media (max-width: 768px) {
    padding: 18px 12px 14px;

    .header {
      margin-bottom: 14px;

      .title {
        font-size: 22px;
      }
    }

    .article-table {
      .cover {
        width: 120px;
        height: 82px;
      }

      .description {
        .article-title {
          font-size: 20px;
        }

        .abstract {
          font-size: 15px;
        }

        .footer {
          .status {
            font-size: 12px;
          }
        }
      }
    }
  }
}
</style>
