-- MySQL dump 10.13  Distrib 9.6.0, for Linux (x86_64)
--
-- Host: localhost    Database: blog_db
-- ------------------------------------------------------
-- Server version	9.6.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '1bf2ea9b-0595-11f1-a6d2-3e5d9c79e6fc:1-298';

--
-- Table structure for table `advertisements`
--

DROP TABLE IF EXISTS `advertisements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `advertisements` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `ad_image` varchar(255) DEFAULT NULL,
  `link` longtext,
  `title` longtext,
  `content` longtext,
  PRIMARY KEY (`id`),
  KEY `idx_advertisements_deleted_at` (`deleted_at`),
  KEY `fk_advertisements_image` (`ad_image`),
  CONSTRAINT `fk_advertisements_image` FOREIGN KEY (`ad_image`) REFERENCES `images` (`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `advertisements`
--

LOCK TABLES `advertisements` WRITE;
/*!40000 ALTER TABLE `advertisements` DISABLE KEYS */;
/*!40000 ALTER TABLE `advertisements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `article_categories`
--

DROP TABLE IF EXISTS `article_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `article_categories` (
  `category` varchar(191) NOT NULL,
  `number` bigint DEFAULT NULL,
  PRIMARY KEY (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `article_categories`
--

LOCK TABLES `article_categories` WRITE;
/*!40000 ALTER TABLE `article_categories` DISABLE KEYS */;
INSERT INTO `article_categories` VALUES ('做饭',4),('后端',1),('教学',1),('教程',1);
/*!40000 ALTER TABLE `article_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `article_likes`
--

DROP TABLE IF EXISTS `article_likes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `article_likes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `article_id` longtext,
  `user_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_article_likes_deleted_at` (`deleted_at`),
  KEY `fk_article_likes_user` (`user_id`),
  CONSTRAINT `fk_article_likes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `article_likes`
--

LOCK TABLES `article_likes` WRITE;
/*!40000 ALTER TABLE `article_likes` DISABLE KEYS */;
INSERT INTO `article_likes` VALUES (1,'2026-03-18 23:36:37.279','2026-03-18 23:36:37.279','2026-03-18 23:36:44.126','lTFxAZ0BaeCoCi5PQIQW',3),(2,'2026-03-18 23:36:44.524','2026-03-18 23:36:44.524',NULL,'lTFxAZ0BaeCoCi5PQIQW',3);
/*!40000 ALTER TABLE `article_likes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `article_tags`
--

DROP TABLE IF EXISTS `article_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `article_tags` (
  `tag` varchar(191) NOT NULL,
  `number` bigint DEFAULT NULL,
  PRIMARY KEY (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `article_tags`
--

LOCK TABLES `article_tags` WRITE;
/*!40000 ALTER TABLE `article_tags` DISABLE KEYS */;
INSERT INTO `article_tags` VALUES ('code',1),('test',1),('test1',1),('test2',1),('做饭',2),('教学',1),('教程',2),('炒菜',3);
/*!40000 ALTER TABLE `article_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `article_id` longtext,
  `p_id` bigint unsigned DEFAULT NULL,
  `user_uuid` char(36) DEFAULT NULL,
  `content` longtext,
  PRIMARY KEY (`id`),
  KEY `idx_comments_deleted_at` (`deleted_at`),
  KEY `fk_comments_children` (`p_id`),
  KEY `fk_comments_user` (`user_uuid`),
  CONSTRAINT `fk_comments_children` FOREIGN KEY (`p_id`) REFERENCES `comments` (`id`),
  CONSTRAINT `fk_comments_user` FOREIGN KEY (`user_uuid`) REFERENCES `users` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
INSERT INTO `comments` VALUES (1,'2026-03-05 20:49:03.265','2026-03-05 20:49:03.265',NULL,'3tMJvpwBAXw9-pKp19YK',NULL,'626efbcf-e9bd-4266-be24-8ad11c19e995','受益匪浅啊！！！'),(2,'2026-03-18 23:37:01.378','2026-03-18 23:37:01.378',NULL,'lTFxAZ0BaeCoCi5PQIQW',NULL,'01b3fdb1-0c08-4c62-8d9b-1ad3763e1759','支持哦\n![](/emoji/xiaochun_emoji_44.png)![](/emoji/xiaochun_emoji_34.png)');
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feedbacks`
--

DROP TABLE IF EXISTS `feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedbacks` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `user_uuid` char(36) DEFAULT NULL,
  `content` longtext,
  `reply` longtext,
  PRIMARY KEY (`id`),
  KEY `idx_feedbacks_deleted_at` (`deleted_at`),
  KEY `fk_feedbacks_user` (`user_uuid`),
  CONSTRAINT `fk_feedbacks_user` FOREIGN KEY (`user_uuid`) REFERENCES `users` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedbacks`
--

LOCK TABLES `feedbacks` WRITE;
/*!40000 ALTER TABLE `feedbacks` DISABLE KEYS */;
INSERT INTO `feedbacks` VALUES (1,'2026-03-09 19:58:16.536','2026-03-18 23:50:15.068',NULL,'626efbcf-e9bd-4266-be24-8ad11c19e995','提个意见。','收到'),(2,'2026-03-18 23:50:39.250','2026-03-18 23:51:03.479',NULL,'01b3fdb1-0c08-4c62-8d9b-1ad3763e1759','后台页面可以更漂亮一点','收到，作者努努力');
/*!40000 ALTER TABLE `feedbacks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `footer_links`
--

DROP TABLE IF EXISTS `footer_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `footer_links` (
  `title` varchar(191) NOT NULL,
  `link` longtext,
  PRIMARY KEY (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `footer_links`
--

LOCK TABLES `footer_links` WRITE;
/*!40000 ALTER TABLE `footer_links` DISABLE KEYS */;
/*!40000 ALTER TABLE `footer_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `friend_links`
--

DROP TABLE IF EXISTS `friend_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friend_links` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `link` longtext,
  `name` longtext,
  `description` longtext,
  PRIMARY KEY (`id`),
  KEY `idx_friend_links_deleted_at` (`deleted_at`),
  KEY `fk_friend_links_image` (`logo`),
  CONSTRAINT `fk_friend_links_image` FOREIGN KEY (`logo`) REFERENCES `images` (`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friend_links`
--

LOCK TABLES `friend_links` WRITE;
/*!40000 ALTER TABLE `friend_links` DISABLE KEYS */;
/*!40000 ALTER TABLE `friend_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `images` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `name` longtext,
  `url` varchar(255) DEFAULT NULL,
  `category` bigint DEFAULT NULL,
  `storage` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uni_images_url` (`url`),
  KEY `idx_images_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `images`
--

LOCK TABLES `images` WRITE;
/*!40000 ALTER TABLE `images` DISABLE KEYS */;
INSERT INTO `images` VALUES (1,'2026-03-05 20:47:16.257','2026-03-05 20:47:21.829',NULL,'f031414b3126f56c2b70bdc7db713902-20260305204716.png','/uploads/image/f031414b3126f56c2b70bdc7db713902-20260305204716.png',3,0),(2,'2026-03-18 22:28:15.520','2026-03-18 22:28:17.394',NULL,'398bfab32bd02bee559ce64bbc660b0d-20260318222815.webp','/uploads/image/398bfab32bd02bee559ce64bbc660b0d-20260318222815.webp',3,0),(3,'2026-03-18 22:30:36.395','2026-03-18 22:30:37.910',NULL,'aadc56a19d5dbf12a79e0cf20ab0688a-20260318223036.webp','/uploads/image/aadc56a19d5dbf12a79e0cf20ab0688a-20260318223036.webp',3,0),(4,'2026-03-18 22:53:48.415','2026-03-18 22:54:52.431',NULL,'5f111fa55ede349515e5fc95ef78a2c1-20260318225348.webp','/uploads/image/5f111fa55ede349515e5fc95ef78a2c1-20260318225348.webp',3,0),(5,'2026-03-27 22:48:13.118','2026-03-29 20:19:25.170',NULL,'0612e1a744e02612ed6a3cf18793a7a9-20260327224813.png','/uploads/image/0612e1a744e02612ed6a3cf18793a7a9-20260327224813.png',0,0),(6,'2026-03-27 22:52:19.575','2026-03-27 22:54:44.178',NULL,'91f0c1b82966f81bc34ce643ccb74ffc-20260327225219.png','/uploads/image/91f0c1b82966f81bc34ce643ccb74ffc-20260327225219.png',0,0),(7,'2026-03-27 22:55:01.671','2026-03-27 22:56:07.822',NULL,'a12d6bc6a7e080c8792494276517f3e0-20260327225501.png','/uploads/image/a12d6bc6a7e080c8792494276517f3e0-20260327225501.png',0,0),(8,'2026-03-27 22:56:14.648','2026-03-27 22:59:08.824',NULL,'a12d6bc6a7e080c8792494276517f3e0-20260327225614.png','/uploads/image/a12d6bc6a7e080c8792494276517f3e0-20260327225614.png',0,0),(9,'2026-03-27 22:59:13.229','2026-03-27 23:05:40.049',NULL,'a12d6bc6a7e080c8792494276517f3e0-20260327225913.png','/uploads/image/a12d6bc6a7e080c8792494276517f3e0-20260327225913.png',0,0),(10,'2026-03-27 23:05:46.744','2026-03-29 20:19:26.322',NULL,'3cf266d30830714e3e0a14e0fc509bd8-20260327230546.png','/uploads/image/3cf266d30830714e3e0a14e0fc509bd8-20260327230546.png',0,0),(11,'2026-03-29 20:26:49.739','2026-03-29 20:26:49.739',NULL,'d976bea23bf421bc313db90e736ecbb6-20260329202649.webp','/uploads/image/d976bea23bf421bc313db90e736ecbb6-20260329202649.webp',0,0),(12,'2026-03-29 20:31:37.228','2026-03-29 20:31:37.228',NULL,'d976bea23bf421bc313db90e736ecbb6-20260329203137.webp','/uploads/image/d976bea23bf421bc313db90e736ecbb6-20260329203137.webp',0,0),(13,'2026-03-29 20:32:35.336','2026-03-29 20:32:35.336',NULL,'d976bea23bf421bc313db90e736ecbb6-20260329203235.webp','/uploads/image/d976bea23bf421bc313db90e736ecbb6-20260329203235.webp',0,0),(14,'2026-03-29 20:43:14.950','2026-03-29 20:51:13.035',NULL,'d976bea23bf421bc313db90e736ecbb6-20260329204314.webp','/uploads/image/d976bea23bf421bc313db90e736ecbb6-20260329204314.webp',3,0),(15,'2026-03-29 21:13:56.964','2026-03-29 21:13:59.160',NULL,'15f9976d7df15fca7a3b8409cd6fd195-20260329211356.png','/uploads/image/15f9976d7df15fca7a3b8409cd6fd195-20260329211356.png',3,0),(16,'2026-03-29 21:17:53.977','2026-03-29 21:18:37.536',NULL,'e2098d5c2b59b29b06fa5ec62a803454-20260329211753.png','/uploads/image/e2098d5c2b59b29b06fa5ec62a803454-20260329211753.png',3,0);
/*!40000 ALTER TABLE `images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jwt_blacklists`
--

DROP TABLE IF EXISTS `jwt_blacklists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jwt_blacklists` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `jwt` text,
  PRIMARY KEY (`id`),
  KEY `idx_jwt_blacklists_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jwt_blacklists`
--

LOCK TABLES `jwt_blacklists` WRITE;
/*!40000 ALTER TABLE `jwt_blacklists` DISABLE KEYS */;
INSERT INTO `jwt_blacklists` VALUES (1,'2026-03-09 15:30:57.598','2026-03-09 15:30:57.598',NULL,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySUQiOjEsImlzcyI6ImdvX2Jsb2ciLCJhdWQiOlsiVEFQIl0sImV4cCI6MTc3MzMxODc1OX0.Q1wnaO3gEqlEvVadSvmdpvtu_S9MtrjBtcgfRu-kmXQ'),(2,'2026-03-09 19:54:23.310','2026-03-09 19:54:23.310',NULL,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySUQiOjEsImlzcyI6ImdvX2Jsb2ciLCJhdWQiOlsiVEFQIl0sImV4cCI6MTc3MzY2MTgxN30.Il5M9iqX4rTsfIA7NfDR6hXGMOGsy0Jpf1gh8eKc9xw'),(3,'2026-03-09 20:59:35.293','2026-03-09 20:59:35.293',NULL,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySUQiOjEsImlzcyI6ImdvX2Jsb2ciLCJhdWQiOlsiVEFQIl0sImV4cCI6MTc3MzY2MjEzM30.pzT7OZqmsXxYSDvMtHWWhdyV4GxBOvKSfcgluzbkWpk'),(4,'2026-03-18 21:43:36.891','2026-03-18 21:43:36.891',NULL,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySUQiOjEsImlzcyI6ImdvX2Jsb2ciLCJhdWQiOlsiVEFQIl0sImV4cCI6MTc3NDQ0NDQ2MH0.z4tXqlq0xI_d4D6MHvlH_gnbBT9mP9ZEDD69EaP4P3g'),(5,'2026-03-18 22:01:27.335','2026-03-18 22:01:27.335',NULL,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySUQiOjEsImlzcyI6ImdvX2Jsb2ciLCJhdWQiOlsiVEFQIl0sImV4cCI6MTc3NDQ0NjIyNX0.lAkudLLDz5GUXXiSdUq7No9rQdB0Kjq5-zmSYTF8LuA');
/*!40000 ALTER TABLE `jwt_blacklists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logins`
--

DROP TABLE IF EXISTS `logins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logins` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `login_method` longtext,
  `ip` longtext,
  `address` longtext,
  `os` longtext,
  `device_info` longtext,
  `browser_info` longtext,
  `status` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_logins_deleted_at` (`deleted_at`),
  KEY `fk_logins_user` (`user_id`),
  CONSTRAINT `fk_logins_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logins`
--

LOCK TABLES `logins` WRITE;
/*!40000 ALTER TABLE `logins` DISABLE KEYS */;
INSERT INTO `logins` VALUES (1,'2026-03-05 20:32:40.166','2026-03-05 20:32:40.166',NULL,1,'email','127.0.0.1','未知','Windows','Other','Edge',200),(2,'2026-03-09 19:50:17.947','2026-03-09 19:50:17.947',NULL,1,'email','127.0.0.1','未知','Windows','Other','Edge',200),(3,'2026-03-09 19:55:34.352','2026-03-09 19:55:34.352',NULL,1,'email','127.0.0.1','未知','Windows','Other','Edge',200),(4,'2026-03-09 20:59:35.418','2026-03-09 20:59:35.418',NULL,1,'email','127.0.0.1','未知','Windows','Other','Edge',200),(5,'2026-03-18 21:14:21.221','2026-03-18 21:14:21.221',NULL,1,'email','127.0.0.1','未知','Windows','Other','Edge',200),(6,'2026-03-18 21:43:45.515','2026-03-18 21:43:45.515',NULL,1,'email','127.0.0.1','未知','Windows','Other','Edge',200),(7,'2026-03-18 22:01:40.762','2026-03-18 22:01:40.762',NULL,1,'email','127.0.0.1','未知','Windows','Other','Edge',200),(8,'2026-03-18 22:10:19.490','2026-03-18 22:10:19.490',NULL,3,'email','127.0.0.1','未知','Windows','Other','Edge',200),(9,'2026-03-26 16:18:53.357','2026-03-26 16:18:53.357',NULL,1,'email','127.0.0.1','未知','Windows','Other','Edge',200),(10,'2026-03-26 21:17:30.747','2026-03-26 21:17:30.747',NULL,3,'email','127.0.0.1','未知','Windows','Other','Edge',200);
/*!40000 ALTER TABLE `logins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `uuid` char(36) DEFAULT NULL,
  `username` longtext,
  `password` longtext,
  `email` longtext,
  `openid` longtext,
  `avatar` varchar(255) DEFAULT NULL,
  `address` longtext,
  `signature` varchar(191) DEFAULT '签名是空白的，这位用户似乎比较低调。',
  `role_id` bigint DEFAULT NULL,
  `register` bigint DEFAULT NULL,
  `freeze` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uni_users_uuid` (`uuid`),
  KEY `idx_users_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'2026-03-03 17:33:45.957','2026-03-09 19:55:06.726',NULL,'626efbcf-e9bd-4266-be24-8ad11c19e995','LLLRhys','$2a$10$YCxGwV0X/RlZoc7mlXNZ.uMgLzs/XK6wbbvaAyfwDWsUBS4iOSeei','2528765108@qq.com','','/image/avatar.jpg','广州市天河区','哥只是个传说...',2,0,0),(3,'2026-03-18 22:10:19.095','2026-03-18 22:10:19.095',NULL,'01b3fdb1-0c08-4c62-8d9b-1ad3763e1759','bbb','$2a$10$qjwSsWlcQqjhS64h2zLXBe5FcqZuvJ0g.nvd9/H3wjSY/GvzBiBBy','3347490138@qq.com','','/image/avatar.jpg','','签名是空白的，这位用户似乎比较低调。',1,0,0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-29 13:30:07
