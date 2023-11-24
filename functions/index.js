const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

// AniList GraphQL APIエンドポイント
const ANILIST_API_URL = 'https://graphql.anilist.co';

exports.fetchAndStoreAnimeData = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  try {
    // AniList APIからデータを取得
    const animeData = await fetchAnimeDataFromAniList();
    // Firestoreにデータを保存
    await storeAnimeDataInFirestore(animeData);
    console.log('Data fetch and store completed successfully.');
  } catch (error) {
    console.error('Error fetching and storing anime data:', error);
  }
});

async function fetchAnimeDataFromAniList() {
  // GraphQLクエリ
  const query = `
  {
    Page(page: 1) {
      media(isAdult: false) {
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

  // POSTリクエストのオプションを設定
  const options = {
    method: 'POST',
    url: ANILIST_API_URL,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    data: {
      query: query
    }
  };

  // AniList APIへのリクエストを送信
  const response = await axios(options);
  // 応答からアニメデータを取得
  return response.data.data.Page.media;
}

async function storeAnimeDataInFirestore(animeList) {
  const db = admin.firestore();

  let batch = db.batch();

  animeList.forEach((anime) => {
    const animeRef = db.collection('Anime').doc(`${anime.id}`);
    batch.set(animeRef, {
      id: anime.id,
      title: anime.title.native,
      season-year: anime.seasonYear,
      season: anime.season,
      episodes: anime.episodes,
      status: anime.status
    });
  });

  // Firestoreへのバッチ書き込みをコミット
  await batch.commit();
}
