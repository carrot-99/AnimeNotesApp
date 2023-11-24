const admin = require('firebase-admin');
const axios = require('axios');

// Firebaseのサービスアカウントキーを使用して初期化
const serviceAccount = require('./animenotesapp-firebase-adminsdk-uofme-334ee3c674.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function getAnimeData(page) {
    try {
      // AniList APIのGraphQLクエリ
      const query = `
        query ($page: Int, $perPage: Int) {
          Page(page: $page, perPage: $perPage) {
            pageInfo {
              total
              currentPage
              lastPage
              hasNextPage
            }
            media(isAdult: false, sort: POPULARITY_DESC) {
              id
              title {
                native
              }
              seasonYear
              season
              episodes
              status
            }
          }
        }
      `;
  
      // AniList APIのURLとGraphQLクエリを使用してリクエスト
      const variables = {
        page: page,
        perPage: 50 // 1ページあたりのアイテム数を増やす
      };
  
      const response = await axios.post('https://graphql.anilist.co', {
        query: query,
        variables: variables
      });
  
      // 取得したデータをFirestoreに保存
      const animeList = response.data.data.Page.media;
      const pageInfo = response.data.data.Page.pageInfo;
      
      for (const anime of animeList) {
        const docRef = db.collection('animes').doc(String(anime.id)); // IDを文字列に変換して使用
        await docRef.set(anime);
      }
  
      console.log(`Page ${pageInfo.currentPage} data saved to Firestore!`);
      
      // 次のページがある場合は再帰的に関数を呼び出す
      if (pageInfo.hasNextPage) {
        await getAnimeData(pageInfo.currentPage + 1);
      }
    } catch (error) {
      console.error("Error fetching data: ", error);
    }
  }
  
  // 最初のページから開始
  getAnimeData(1);