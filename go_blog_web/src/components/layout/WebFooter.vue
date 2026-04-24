<template>
  <div class="web-footer">
    <div class="container">
      <div class="footer-left">
        <div class="full-logo">
          <el-image
              :src="websiteStore.state.websiteInfo.full_logo===''?'/image/full_logo.png':websiteStore.state.websiteInfo.full_logo"
              alt=""/>
        </div>
        <el-text>{{ websiteStore.state.websiteInfo.description }}</el-text>
      </div>
      <div class="footer-center">
        <el-space size="large" spacer="|">
          <div class="footer-link" v-for="item in footerLinkList" :key="item.title">
            <el-link :href=item.link>{{ item.title }}</el-link>
          </div>
        </el-space>
        <div class="bottom">
          <div class="social-link">
            <el-link :href=websiteStore.state.websiteInfo.github_url :underline="false">
              <el-image src="/image/github.png" alt="github"></el-image>
            </el-link>
            <el-image class="qq-community" src="/image/qqCommunity.jpg" alt="qq-community"></el-image>
          </div>
          <div class="filing">
            <el-image src="/image/filing.png" alt=""/>
            <el-link href="https://beian.miit.gov.cn/#/Integrated/index" :underline="false">
              {{ websiteStore.state.websiteInfo.icp_filing }}
            </el-link>
            <el-link :href=publicSecurityFilingLink :underline="false">
              {{ websiteStore.state.websiteInfo.public_security_filing }}
            </el-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {useWebsiteStore} from "@/stores/website";
import {computed} from "vue";
import {ref} from "vue";
import {type FooterLink, websiteFooterLink} from "@/api/website";

const footerLinkList=ref<FooterLink[]>([])

const getFooterLinkList =async ()=>{
  const res = await websiteFooterLink()
  if (res.code===0){
    footerLinkList.value=res.data
  }
}

getFooterLinkList()

const websiteStore = useWebsiteStore()

const publicSecurityFilingLink = computed(() => "http://www.beian.gov.cn/portal/registerSystemInfo?recordcode=" + websiteStore.state.websiteInfo.public_security_filing.match(/\d+/))

</script>


<style scoped lang="scss">
.web-footer {
  display: flex;
  justify-content: center;

  .container {
    display: flex;
    max-width: 1400px;
    width: 100%;

    .footer-left {
      width: 30%;
      margin-bottom: auto;
      margin-top: auto;
      padding-top: 14px;

      .el-image {
        height: 80px;
      }
    }

    .footer-center {
      width: 70%;
      margin: auto 5%;

      .footer-link {
        .el-link {
          margin-top: 20px;
          margin-bottom: 20px;
        }
      }

      .bottom {
        display: grid;
        grid-template-columns: 1fr auto 1fr;
        align-items: center;
        margin-top: 20px;

        .social-link {
          grid-column: 2;
          display: flex;
          align-items: center;
          gap: 24px;

          .el-link,
          .el-image {
            display: flex;
            align-items: center;
          }

          .el-image {
            height: 36px;
            width: auto;
          }

          .qq-community {
            height: 150px;
            border-radius: 4px;
          }
        }

        .filing {
          grid-column: 3;
          justify-self: end;
          display: flex;

          .el-image {
            margin-bottom: auto;
            margin-top: auto;
          }

          .el-link {
            margin-left: 5px;
            margin-right: 10px;
          }
        }
      }


    }
  }
}
</style>
