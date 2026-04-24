<template>
  <div class="index">
    <web-navbar/>
    <el-container class="main-content">
      <div class="container">
        <el-main>
          <article-list/>
        </el-main>
      </div>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import WebNavbar from "@/components/layout/WebNavbar.vue";
import ArticleList from "@/components/pages/ArticleList.vue";
</script>

<style scoped lang="scss">
.index {
  .main-content {
    display: flex;
    justify-content: center;
    padding-top: 84px;

    .container {
      display: flex;
      max-width: 980px;
      width: 100%;
      padding: 0 20px;

      .el-main {
        width: 100%;
      }
    }
  }

}
</style>
