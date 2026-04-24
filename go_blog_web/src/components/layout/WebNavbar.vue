<template>
  <div :class="{'web-navbar': true,show: isShow}">
    <div class="container">
      <logo/>
      <div class="web-menu">
        <el-menu mode="horizontal" :ellipsis="false" :router="true" :default-active="$route.path">
          <template v-for="item in menuList">
            <el-menu-item :index="item.name"><span>{{ item.title }}</span></el-menu-item>
          </template>
        </el-menu>
      </div>
      <div class="right-actions">
        <el-button class="feedback-button" text @click="goFeedback">反馈</el-button>
        <el-dialog
            v-model="feedbackVisible"
            width="720"
            destroy-on-close
            align-center
        >
          <template #header>
            意见反馈
          </template>
          <feedback/>
        </el-dialog>
        <auth-popover/>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import AuthPopover from "@/components/common/AuthPopover.vue";
import Feedback from "@/components/pages/Feedback.vue";
import Logo from "@/components/widgets/Logo.vue";
import {ref} from "vue";
import {onUnmounted} from "vue";

const isShow = ref(true)

const props = defineProps<{
  noScroll?: boolean
}>()

if (!props.noScroll) {
  isShow.value = false
  window.addEventListener("scroll", scroll)
  scroll()
}

function scroll() {
  let top = document.documentElement.scrollTop
  isShow.value = top >= 100;
}

onUnmounted(() => {
  if (!props.noScroll) {
    window.removeEventListener("scroll", scroll)
  }
})

interface MenuItem {
  title: string;
  name: string;
}

const menuList: MenuItem[] = [
  {
    title: "首页",
    name: "/",
  },
  {
    title: "搜索",
    name: "/search",
  },
  {
    title: "关于",
    name: "/about",
  }
]

const feedbackVisible = ref(false)

const goFeedback = () => {
  feedbackVisible.value = true
}

</script>


<style scoped lang="scss">
.web-navbar {
  display: flex;
  justify-content: center;
  width: 100%;
  position: fixed;
  z-index: 6;
  color: dimgray;
  --el-menu-text-color: dimgray;
  --color: dimgray;

  &.show {
    top: 0;
    background-color: white;
    color: black;
    --el-menu-text-color: black;
    --color: black;

    .container {
      margin-top: 8px;
    }
  }

  .container {
    display: flex;
    max-width: 1400px;
    width: 100%;

    .logo {
      height: 60px;
      width: 200px;
    }

    .web-menu {
      margin-left: 20px;

      .el-menu {
        background-color: transparent;
        border-bottom: none;
        --el-menu-item-font-size: 20px;

        .el-menu-item {
          border-bottom: none;
          background-color: transparent;
        }
      }
    }

    .right-actions {
      margin-left: auto;
      margin-top: auto;
      margin-bottom: auto;
      padding-right: 20px;
      display: flex;
      align-items: center;
      gap: 8px;

      .feedback-button {
        color: #409eff;
      }
    }
  }
}
</style>
