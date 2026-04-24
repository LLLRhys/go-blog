<template xmlns="http://www.w3.org/1999/html">
  <div class="home">
    <div class="header">
      <el-card class="user-card">
        <el-row>
          你好，{{ userStore.state.userInfo.username }}，今天也要加油啊！
        </el-row>
      </el-card>
    </div>

    <div class="content">
      <el-card class="entrance-card">
        <el-row class="title">
          快捷入口
        </el-row>
        <div class="button-group">
          <div class="button-item" v-for="item in entranceList">
            <el-button :icon="item.icon" :type="item.type" plain @click="handleClick(item)"/>
            {{ item.title }}
          </div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import {useUserStore} from "@/stores/user";
import router from "@/router";
import {type Tag, useTagStore} from "@/stores/tag";

const userStore = useUserStore()

interface Entrance {
  title: string
  name: string;
  icon: string;
  type: string;
}

const entranceList: Entrance[] = [
  {
    title: '我的信息',
    name: 'user-info',
    icon: 'Postcard',
    type: 'primary',
  },
  {
    title: '我的收藏',
    name: 'user-star',
    icon: 'Star',
    type: 'warning',
  },
  {
    title: '我的评论',
    name: 'user-comment',
    icon: 'ChatDotRound',
    type: 'info',
  },
  {
    title: '我的反馈',
    name: 'user-feedback',
    icon: 'Message',
    type: 'success',
  }
]

const tagStore = useTagStore()

function handleClick(item: Entrance) {
  const newTag: Tag = {
    title: item.title,
    name: item.name
  }
  const exists = tagStore.state.tags.some(tag => tag.name === newTag.name);
  if (exists) {
    return;
  }
  tagStore.state.tags.push(newTag);
  router.push({name:item.name})
}

</script>

<style scoped lang="scss">
.home {
  .header {
    margin-bottom: 20px;

    .user-card {
      .el-row {
        font-size: 32px;
      }
    }
  }

  .content {
    display: block;

    .entrance-card {
      width: 100%;

      .title {
        font-size: 24px;
      }

      .button-group {
        display: flex;
        margin-top: 20px;
        margin-bottom: 20px;

        .button-item {
          display: flex;
          flex-direction: column;
          align-items: center;
          width: 80px;

          .el-button {
            border: none;
            --el-font-size-base: 32px;
            height: 62px;
            background-color: transparent;
          }
        }
      }
    }
  }
}
</style>
