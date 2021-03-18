'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "manifest.json": "190711d25f577894a01d6e4cc37c8249",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"assets/NOTICES": "9c37a7e522c303b12472b4b09e0ab3b1",
"assets/assets/fonts/Poppins-Black.ttf": "42cf9f0820d16f3ac2c26a7710ce70f2",
"assets/assets/fonts/Poppins-Thin.ttf": "c0fafa8397437c95848724aed686d63b",
"assets/assets/fonts/Poppins-Light.ttf": "2a47a29ceb33c966c8d79f8d5a5ea448",
"assets/assets/fonts/Poppins-ExtraBold.ttf": "6b78c7ec468eb0e13c6c5c4c39203986",
"assets/assets/fonts/Poppins-ExtraLight.ttf": "8ea2657f263b6b2a404bfb57f4160013",
"assets/assets/fonts/Poppins-Regular.ttf": "41e8dead03fb979ecc23b8dfb0fef627",
"assets/assets/fonts/Poppins-Medium.ttf": "ba95810b56f476990ca71d15139d5111",
"assets/assets/fonts/Poppins-Bold.ttf": "c23534acbeddbaadfd0ab2d2bbfdfc84",
"assets/assets/locales/sv_SE.po": "e9ecf37c0bb566de30f1e84a3a80c18f",
"assets/assets/svg/empty.svg": "60e7977b8617b440b7053e43e46969e7",
"assets/assets/svg/company.svg": "ac8f4fc6262cae56a87f9e96a954b887",
"assets/assets/svg/access.svg": "8e98938612ed857a808b297f30ea9e89",
"assets/assets/svg/success.svg": "40da70e5560b37acf8c2824a95f6ea21",
"assets/assets/svg/data.svg": "879a45e6603d6cedf31dd814cf40bcf2",
"assets/assets/svg/data_sources.svg": "b88e216b9868297de85a96b6b367c88c",
"assets/assets/svg/activity.svg": "d54b51a786f84795530d97caf3813e7d",
"assets/assets/svg/date.svg": "2f10b85920e9ee748d164f45f9076efb",
"assets/assets/svg/remote_work.svg": "c33a013b816eca66cf92599a3739caa6",
"assets/assets/svg/data_processing.svg": "d3624abbfb8a03fef323a834a72bb4a0",
"assets/assets/png/apple_health_logo.png": "29141e134365aa8a33de790b6431271e",
"assets/assets/png/google_fit_logo.png": "7b6144ac2d459fcda75ab3f9b160ad0e",
"assets/assets/png/fitbit_logo.png": "d3ba461ac67df16bbfd8d6ff692d5fb4",
"assets/assets/png/gu_logo.png": "6b87c4abbb349fb884c8db37b78758c4",
"assets/assets/png/garmin_logo.png": "68ee5e478b3880fcca025ba2d0471fcb",
"assets/fonts/MaterialIcons-Regular.otf": "1288c9e28052e028aba623321f7826ac",
"assets/AssetManifest.json": "4f05631ebe3ba644c39acfef1562fea5",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/country_list_pick/flags/cn.png": "453d855f70ef7b89fac99895773f2535",
"assets/packages/country_list_pick/flags/ao.png": "2a02b1dab7b7eef4600bde31e20d656d",
"assets/packages/country_list_pick/flags/bb.png": "482aba486df393337e7ca37e1809b34a",
"assets/packages/country_list_pick/flags/cg.png": "03fd398d46ee2e45771139ba34595da7",
"assets/packages/country_list_pick/flags/kg.png": "52299a932b7d90ea7ae217ee20b90a53",
"assets/packages/country_list_pick/flags/mh.png": "5d44d2d6bc8ef667daaab82c431ca023",
"assets/packages/country_list_pick/flags/gy.png": "d9ac767c16b5d3a2ccd303b6bfc9a202",
"assets/packages/country_list_pick/flags/wf.png": "b7e46678b1f20fd6bc752a0fb34f492e",
"assets/packages/country_list_pick/flags/an.png": "f631f7f4261fef69ab47a15437b819e9",
"assets/packages/country_list_pick/flags/kp.png": "6170ee90cf354cd114e7f4eb99896700",
"assets/packages/country_list_pick/flags/cm.png": "f6e9475b28d20bcc3123dd5d0cca3279",
"assets/packages/country_list_pick/flags/gb-wls.png": "a52fc5da481dc1861efd0056b671bea2",
"assets/packages/country_list_pick/flags/tm.png": "587e852cf79984b2874546d9cbdf339d",
"assets/packages/country_list_pick/flags/kn.png": "7553a352430f9740a081151c3ab089eb",
"assets/packages/country_list_pick/flags/dk.png": "4809c56e7a1f204328e43339f6f84db5",
"assets/packages/country_list_pick/flags/pw.png": "3fe5f5ac165f4d7a11847fa58323ebe3",
"assets/packages/country_list_pick/flags/lu.png": "e938221063036026b204215c622226c3",
"assets/packages/country_list_pick/flags/fj.png": "038d2866c0d421dedc3ec8a3a08d81e7",
"assets/packages/country_list_pick/flags/bz.png": "a01fc77bbf3d59b7589879f8dd211912",
"assets/packages/country_list_pick/flags/eg.png": "163974b6e28267d22bb86eb53de4be63",
"assets/packages/country_list_pick/flags/pr.png": "4c013d5006b46b1b1f3371ee10f896cd",
"assets/packages/country_list_pick/flags/lv.png": "1c8de39890043c6b6c3ac9192965ecfc",
"assets/packages/country_list_pick/flags/th.png": "26c730c4f3d8990011d72b62cefedff7",
"assets/packages/country_list_pick/flags/at.png": "608769b0492b16839f9f3e368ea32990",
"assets/packages/country_list_pick/flags/im.png": "b39b706ce090a11b45f199faee9a1536",
"assets/packages/country_list_pick/flags/ax.png": "1db33dac4ca169fbb04ff422fe3b32fe",
"assets/packages/country_list_pick/flags/ar.png": "11c38bd60820e7c52352db376cdcfce9",
"assets/packages/country_list_pick/flags/to.png": "5ff2d5324888c0836390dec09203b038",
"assets/packages/country_list_pick/flags/sd.png": "c4ebfd8e408c64752171ed332ecaf84d",
"assets/packages/country_list_pick/flags/dz.png": "9d64cd78c49a15008cbe8652b231798d",
"assets/packages/country_list_pick/flags/gp.png": "1f51e1cf368860492305e56573dc6013",
"assets/packages/country_list_pick/flags/io.png": "696f3b4e093ed2f50057035e71d87652",
"assets/packages/country_list_pick/flags/gs.png": "1556a6cb1f75a23f0593a58bc30989b5",
"assets/packages/country_list_pick/flags/lt.png": "adebbfcb4e666ae83c420572568491eb",
"assets/packages/country_list_pick/flags/sy.png": "4bdfb178d0b5c37d1a49447644810642",
"assets/packages/country_list_pick/flags/bf.png": "6a7837fbb20d1d707edac18a772d0aca",
"assets/packages/country_list_pick/flags/gb-sct.png": "5dc90d9a83c3de79746d0bea814bf645",
"assets/packages/country_list_pick/flags/by.png": "7eb8aca4382b94d17d531ecc675cc4ba",
"assets/packages/country_list_pick/flags/mr.png": "84a0f7bcdcacf970bfaa8fd7c2f4c1d2",
"assets/packages/country_list_pick/flags/be.png": "d7452c934da368ce542b49037a4226fb",
"assets/packages/country_list_pick/flags/it.png": "3e556834b2a2bd13043fc750f2134261",
"assets/packages/country_list_pick/flags/aq.png": "7f7fa7af21fc3dc4a3860fb1af8c4117",
"assets/packages/country_list_pick/flags/tc.png": "3d9368fce5092fa8c7b7f01bee735532",
"assets/packages/country_list_pick/flags/de.png": "c0d0800fa9091a0e8830d78a29e4091a",
"assets/packages/country_list_pick/flags/bl.png": "188d496b200dca60e47c87b852fc89b0",
"assets/packages/country_list_pick/flags/is.png": "67050355a791ebfdbd1ee963b5130073",
"assets/packages/country_list_pick/flags/gu.png": "0760912df59b966b2f5dcd1bacd2630b",
"assets/packages/country_list_pick/flags/cy.png": "dae1d011d2a55114add74dc0bde56400",
"assets/packages/country_list_pick/flags/bj.png": "ecb4f0778612d76a3b2d587a48e6ebd1",
"assets/packages/country_list_pick/flags/gg.png": "486cde076860a1b735e44959cb22afa3",
"assets/packages/country_list_pick/flags/vi.png": "8d9b59da5f89e37d023b1d98eaf3bd57",
"assets/packages/country_list_pick/flags/ss.png": "a35ee2f46bb2775ae97a6243bf488314",
"assets/packages/country_list_pick/flags/ir.png": "55b4c27ee8268c0e4d23a11028a02777",
"assets/packages/country_list_pick/flags/vu.png": "1f3f683c41e68e68ca1e8532826f2238",
"assets/packages/country_list_pick/flags/mk.png": "72c60ba396e6ef68402fd4314fba82be",
"assets/packages/country_list_pick/flags/sa.png": "4860952974607dd9df1e7abf159551d9",
"assets/packages/country_list_pick/flags/mu.png": "756616702622933b34b893646f7cd0eb",
"assets/packages/country_list_pick/flags/jo.png": "aad9bc74c2a920f7c84e5cfe3a762fde",
"assets/packages/country_list_pick/flags/ml.png": "95ab1e6fbcf0b539ad91dac85dd78048",
"assets/packages/country_list_pick/flags/bv.png": "ef598a9fd443a87e16d0bfe79ee38cdf",
"assets/packages/country_list_pick/flags/aw.png": "17d573958530d3787d85839f4e19ef56",
"assets/packages/country_list_pick/flags/jm.png": "f52bd4a303b158adc13398edad699d8f",
"assets/packages/country_list_pick/flags/pg.png": "64e4dab43ebe44ec9c660f865b83cdd5",
"assets/packages/country_list_pick/flags/ne.png": "f283f366eae7933f199f21c386ab2bd5",
"assets/packages/country_list_pick/flags/mc.png": "8686af5cf0dba090f9e8b3bf3db68c6b",
"assets/packages/country_list_pick/flags/fr.png": "02aea38f9e516467efca62ca26b7046e",
"assets/packages/country_list_pick/flags/gq.png": "508308fd6a78dea099ec2f729985099a",
"assets/packages/country_list_pick/flags/iq.png": "9319b4faa07fa82efd33d33ea496e174",
"assets/packages/country_list_pick/flags/re.png": "1f51e1cf368860492305e56573dc6013",
"assets/packages/country_list_pick/flags/nu.png": "444e791cfb272edeb705a95f83185191",
"assets/packages/country_list_pick/flags/gb.png": "4f3d96e67f55b5b8495ff9d104c6872d",
"assets/packages/country_list_pick/flags/fi.png": "13e2f1188d79003d314353820122fc17",
"assets/packages/country_list_pick/flags/cv.png": "b25db20c51c841b496c8668bb5b4d1cf",
"assets/packages/country_list_pick/flags/yt.png": "1f51e1cf368860492305e56573dc6013",
"assets/packages/country_list_pick/flags/ve.png": "1143cb8025ec96e7caca26785962d518",
"assets/packages/country_list_pick/flags/zw.png": "9a81708fa126804fdd75bdcac6cb390f",
"assets/packages/country_list_pick/flags/pf.png": "c24b43b17213fa4bf710cce0a5666cb9",
"assets/packages/country_list_pick/flags/rs.png": "fe38b3c35c08ceb4ffe5372f51112bd0",
"assets/packages/country_list_pick/flags/mg.png": "36a09154b828ca93ef19cd370d3851ff",
"assets/packages/country_list_pick/flags/kz.png": "fca455cb0b4a07700a536999108aa073",
"assets/packages/country_list_pick/flags/il.png": "75608d293f7e1b0b12b17d950b8f918b",
"assets/packages/country_list_pick/flags/ru.png": "4fcf2660173f696388dea92667de164a",
"assets/packages/country_list_pick/flags/zm.png": "8928cebab223c02f5bac81a969e898eb",
"assets/packages/country_list_pick/flags/us.png": "d954766c5bb2a1c6b89f1371aba07b4c",
"assets/packages/country_list_pick/flags/ro.png": "aeeaef3e507b62f710359e3976b574ce",
"assets/packages/country_list_pick/flags/br.png": "ae1749ed87f9a3afca2851247d4546cc",
"assets/packages/country_list_pick/flags/mv.png": "ff967b27286b888952220588dc0d33c3",
"assets/packages/country_list_pick/flags/td.png": "af99aa9d657ede1ad49ecbb791f26c75",
"assets/packages/country_list_pick/flags/tg.png": "1aac75adea3d024d892392e9fb521c83",
"assets/packages/country_list_pick/flags/af.png": "660f122fdb9e6eee8c23ce283e6c436e",
"assets/packages/country_list_pick/flags/bn.png": "3a12f43c65ad152d9fdeb237aa04af3a",
"assets/packages/country_list_pick/flags/si.png": "c428d79ab05873b881c7851210aa5f29",
"assets/packages/country_list_pick/flags/al.png": "1bf7583a605aa5330ef94c112e5bf9df",
"assets/packages/country_list_pick/flags/tr.png": "29bd4d66e8e156e4daea96ae1673c951",
"assets/packages/country_list_pick/flags/tv.png": "84a68e470361631eb793ace8cbfe88cd",
"assets/packages/country_list_pick/flags/gb-nir.png": "4f3d96e67f55b5b8495ff9d104c6872d",
"assets/packages/country_list_pick/flags/cd.png": "e8f2cea779ce872d08201597b02c597f",
"assets/packages/country_list_pick/flags/cf.png": "45617cf482d8526b23147bc78d00f50d",
"assets/packages/country_list_pick/flags/bm.png": "7fcfe44364e7b13bc9bb6b1d38e67b44",
"assets/packages/country_list_pick/flags/bq.png": "46b0d4835c3c23c0a8d4ef9f55db2b06",
"assets/packages/country_list_pick/flags/as.png": "4fd332ffc9a2faf834357487f1d93e29",
"assets/packages/country_list_pick/flags/ch.png": "ad15a9e9baeabdbb949c694398368e4e",
"assets/packages/country_list_pick/flags/tj.png": "15af71069779d3b0509ffee9251f9588",
"assets/packages/country_list_pick/flags/pn.png": "1b483de59d98dbab49af3a2a818f567c",
"assets/packages/country_list_pick/flags/qa.png": "35de25a58f356e13ac87e140cfc80bb3",
"assets/packages/country_list_pick/flags/so.png": "2fb38d1f81d22648e9fb09fe84889f17",
"assets/packages/country_list_pick/flags/ph.png": "f7d9f8ca1f2f42be3fc16541d8f23f29",
"assets/packages/country_list_pick/flags/tz.png": "c7beca272acad189bdc2aa6a1d6d52c8",
"assets/packages/country_list_pick/flags/ad.png": "1aacf693aed2acfe02e61661bb1d15ca",
"assets/packages/country_list_pick/flags/ma.png": "7023a10ba108e7e3d1904214249025e4",
"assets/packages/country_list_pick/flags/my.png": "4790d277bd7b03b793c9c8a54d0db16c",
"assets/packages/country_list_pick/flags/pl.png": "59b66c03277d662094a5deba6745e448",
"assets/packages/country_list_pick/flags/ua.png": "df5f575fc7266ae93ce527ad3703b7af",
"assets/packages/country_list_pick/flags/mx.png": "ff34b81849b3cbfbc162ae60b79bcdfc",
"assets/packages/country_list_pick/flags/et.png": "e914d5910342f9356198084b624c260d",
"assets/packages/country_list_pick/flags/xk.png": "b945091e2392a5e0947fd034de30ffb6",
"assets/packages/country_list_pick/flags/cr.png": "2048f5b6386d9e67512a6779d5d82128",
"assets/packages/country_list_pick/flags/ga.png": "488e48ef9feb3c76d911a043deee71b8",
"assets/packages/country_list_pick/flags/tw.png": "445e9d2c92a405aaa57b4c62174d0a70",
"assets/packages/country_list_pick/flags/pt.png": "f9a2dd01d695901f6d5df9786fb94b28",
"assets/packages/country_list_pick/flags/bg.png": "a79a31dba572a83d51619b257523ea43",
"assets/packages/country_list_pick/flags/ug.png": "a78b050a73b54f4fe97efda12e6db1f1",
"assets/packages/country_list_pick/flags/kr.png": "1fb2e249ed60a470219a00366d7f147d",
"assets/packages/country_list_pick/flags/tl.png": "03331ba7e3de6f6e56c7a8e427df9757",
"assets/packages/country_list_pick/flags/hu.png": "0b4115c034ece729b7119ab4e3f4bb39",
"assets/packages/country_list_pick/flags/ca.png": "65f9c9629bfe9e4923815813e5431efd",
"assets/packages/country_list_pick/flags/cz.png": "bec7038212c7d05c88b6b22f41ef2630",
"assets/packages/country_list_pick/flags/ht.png": "0dbee740251a8fb814a055fedf859188",
"assets/packages/country_list_pick/flags/dj.png": "12e894c0ced52efd15dfca315a16f33b",
"assets/packages/country_list_pick/flags/nc.png": "27fd7db92e8e95f7f40d551cbea09a85",
"assets/packages/country_list_pick/flags/om.png": "a73a7059c9c05355bdb07671556c2abe",
"assets/packages/country_list_pick/flags/er.png": "d830edf23589c5ddc068cc70a0e19249",
"assets/packages/country_list_pick/flags/um.png": "d954766c5bb2a1c6b89f1371aba07b4c",
"assets/packages/country_list_pick/flags/cx.png": "6d279739de88c345f3e31c124e018c84",
"assets/packages/country_list_pick/flags/jp.png": "6f0b04f379cdc6cc8729e45a76f45290",
"assets/packages/country_list_pick/flags/nz.png": "8653747503cf69d01f4caca15955868a",
"assets/packages/country_list_pick/flags/uz.png": "09314fdd69b5f2f807f34849ab7e58fd",
"assets/packages/country_list_pick/flags/ng.png": "1beb46365517bf1d99b1d5b730db108b",
"assets/packages/country_list_pick/flags/vg.png": "cec52738e3c09558332834ed435c9843",
"assets/packages/country_list_pick/flags/gw.png": "57a0a4704b45fc701e5b8574241b474e",
"assets/packages/country_list_pick/flags/bo.png": "1cf2bc64d508f720372a608f9e47b9bb",
"assets/packages/country_list_pick/flags/id.png": "155344cb61fa85ff8680fe44a0c40515",
"assets/packages/country_list_pick/flags/bh.png": "d0442fb0b456d43e267eedc5e5a1cd09",
"assets/packages/country_list_pick/flags/sx.png": "bc6ff957c83ce667c8fd182d98a3a089",
"assets/packages/country_list_pick/flags/lk.png": "5ca339d7f63b878f1f8b82d43cf9aacf",
"assets/packages/country_list_pick/flags/li.png": "3a5673239686961098d67637847e4c01",
"assets/packages/country_list_pick/flags/sm.png": "bb92ccdf55b3e911b4dbd1ad323025b8",
"assets/packages/country_list_pick/flags/hk.png": "e25e7660ae9e5739632077c31b891d69",
"assets/packages/country_list_pick/flags/fo.png": "a0ce3561039b6741bf8a4e38ec92f2a8",
"assets/packages/country_list_pick/flags/la.png": "7bcfbc9eaf2567e0938499da1fa8ef0b",
"assets/packages/country_list_pick/flags/do.png": "0a1041d6a0498bc11b52fca93c083156",
"assets/packages/country_list_pick/flags/mq.png": "276e66e5e2a76f1e4fdeab5e523c5300",
"assets/packages/country_list_pick/flags/se.png": "d64ec3de57b785c23f588bd3083e538c",
"assets/packages/country_list_pick/flags/ag.png": "a91460a442335d76faaaeb8d97fd27bf",
"assets/packages/country_list_pick/flags/lb.png": "c8b9c19874f273e635bc49de92831fb5",
"assets/packages/country_list_pick/flags/ci.png": "f891481b6d8919fc50cc43e1dec24263",
"assets/packages/country_list_pick/flags/pk.png": "1b66722e1c4f02f3377ec8f2a61c10bf",
"assets/packages/country_list_pick/flags/gl.png": "0bf006d770eb8525708867a301765a95",
"assets/packages/country_list_pick/flags/tk.png": "c2b01fb241c3376142db12a5ca21d75f",
"assets/packages/country_list_pick/flags/gm.png": "e5d632aed932e81f47eecc98de383ec0",
"assets/packages/country_list_pick/flags/za.png": "6d7ebb91ce1fddfabf57176255d332af",
"assets/packages/country_list_pick/flags/mn.png": "7dc35bfb7e8e96d0fc3c30eb008a091a",
"assets/packages/country_list_pick/flags/lr.png": "744134e9ed215c287316f31c9ecb3fed",
"assets/packages/country_list_pick/flags/je.png": "cccc2aa2d3d99a8dccb68785f99139eb",
"assets/packages/country_list_pick/flags/bw.png": "d2e74d89d909ad4a25a9c5717de2f7dc",
"assets/packages/country_list_pick/flags/eu.png": "9071dd73d728d00cd9d28ddc41332275",
"assets/packages/country_list_pick/flags/gh.png": "0e83b81570c011ee260e9404309369bd",
"assets/packages/country_list_pick/flags/md.png": "ab816594f9e3e91424526f8fbbed344b",
"assets/packages/country_list_pick/flags/cc.png": "9d7c8bcf3cdc767a7f31426ee30dab60",
"assets/packages/country_list_pick/flags/cu.png": "ac8319acc61b156f7bdb253c3a04c616",
"assets/packages/country_list_pick/flags/bi.png": "542666e31144f9dcc5f33747354920f8",
"assets/packages/country_list_pick/flags/cw.png": "c4c1ed5b99f70096e8338a8772069446",
"assets/packages/country_list_pick/flags/sl.png": "aa42873d1b3b7097d5bf5394fd7db249",
"assets/packages/country_list_pick/flags/py.png": "b1f3a3e40b9f3bff417d959b3a6e3b79",
"assets/packages/country_list_pick/flags/uy.png": "afc590e6c5e6ec044e854a94aa5c641f",
"assets/packages/country_list_pick/flags/hm.png": "3dbb2351f8350ef5624c6e1997d9b10e",
"assets/packages/country_list_pick/flags/nr.png": "acdf572d1e7621435a326b42d7ad7eae",
"assets/packages/country_list_pick/flags/am.png": "ebf44c9104fdcdc5cafb4ce952a54d59",
"assets/packages/country_list_pick/flags/in.png": "c40656915e40b8697d755adf12d67775",
"assets/packages/country_list_pick/flags/ae.png": "f0a95f247aa9ed04e8b8078fab47d116",
"assets/packages/country_list_pick/flags/sv.png": "cffaa7e9fce1e1b9ff8e9e410d504ebe",
"assets/packages/country_list_pick/flags/cl.png": "83b1b9005caef41c7fd2a6384e4927db",
"assets/packages/country_list_pick/flags/gf.png": "fba33680ae29a3a37d31133809441d62",
"assets/packages/country_list_pick/flags/pm.png": "1f51e1cf368860492305e56573dc6013",
"assets/packages/country_list_pick/flags/ye.png": "103e45a7c439a078ba088fadd20d9405",
"assets/packages/country_list_pick/flags/ls.png": "9e8c59af7733d1254452483c8ca4dfa3",
"assets/packages/country_list_pick/flags/mw.png": "bede1e29f44deb775d43916acb5300b4",
"assets/packages/country_list_pick/flags/es.png": "075c30fd313b802b80b34687e554cf4f",
"assets/packages/country_list_pick/flags/kw.png": "072729cd962f32af330d7b151b15a138",
"assets/packages/country_list_pick/flags/sb.png": "69cf6fb36fda272ff52a4c913f170871",
"assets/packages/country_list_pick/flags/gr.png": "b67f77b18d764959666ab02333f7f661",
"assets/packages/country_list_pick/flags/sh.png": "4f3d96e67f55b5b8495ff9d104c6872d",
"assets/packages/country_list_pick/flags/lc.png": "b780e4dfafbb6b834bc6e57248c0aacc",
"assets/packages/country_list_pick/flags/eh.png": "ba5d85e8e5e77a03c44f70a912191789",
"assets/packages/country_list_pick/flags/no.png": "ef598a9fd443a87e16d0bfe79ee38cdf",
"assets/packages/country_list_pick/flags/au.png": "3dbb2351f8350ef5624c6e1997d9b10e",
"assets/packages/country_list_pick/flags/mp.png": "614bfa3bf97f77850cb0233c08e53db2",
"assets/packages/country_list_pick/flags/ke.png": "a8ab4857f02900810cfcf76a2f3b44e2",
"assets/packages/country_list_pick/flags/sk.png": "87b04462076cf5a131437ffd5806772c",
"assets/packages/country_list_pick/flags/ck.png": "1b007eb85531f253b2ec15e958e3056f",
"assets/packages/country_list_pick/flags/sg.png": "c922d92eccf8c8f495a1015179dcc026",
"assets/packages/country_list_pick/flags/sj.png": "ef598a9fd443a87e16d0bfe79ee38cdf",
"assets/packages/country_list_pick/flags/ba.png": "80ddc6e6f02020d84c657b5d86ff7684",
"assets/packages/country_list_pick/flags/kh.png": "672d4f09957d1bf2fe8f425c3e330233",
"assets/packages/country_list_pick/flags/va.png": "d4076a8fe13f708cb048cf59b2211672",
"assets/packages/country_list_pick/flags/tn.png": "76073847b409dccabe9c1eda3ac05f91",
"assets/packages/country_list_pick/flags/st.png": "73e8c89284ebadf4b92ac3cd9d262c72",
"assets/packages/country_list_pick/flags/ky.png": "5e2507311516d33660dbba97c489813d",
"assets/packages/country_list_pick/flags/ps.png": "01f934c2da8a4d7f75392b6ff251d0f1",
"assets/packages/country_list_pick/flags/dm.png": "4773d4707ada9bb01e74f206fc17abbe",
"assets/packages/country_list_pick/flags/gb-eng.png": "7ad705e446f51de6798a3cd931c678cf",
"assets/packages/country_list_pick/flags/mz.png": "41bada1d37528a6aa55b407ae956a815",
"assets/packages/country_list_pick/flags/ec.png": "3f59e5070153ea5efe7da4561d311aa8",
"assets/packages/country_list_pick/flags/ki.png": "acc84e8f81d0d523ef834cb4b5e0780a",
"assets/packages/country_list_pick/flags/np.png": "6e91204f10b316cd7cd94a847f294fe9",
"assets/packages/country_list_pick/flags/fm.png": "3ca2968179d1119db38353ef014a6196",
"assets/packages/country_list_pick/flags/mf.png": "1f51e1cf368860492305e56573dc6013",
"assets/packages/country_list_pick/flags/rw.png": "1ef7abcf069ef349ad94739a5632a38b",
"assets/packages/country_list_pick/flags/ai.png": "9ad8f6fbd2dfffc221ddc86157be356f",
"assets/packages/country_list_pick/flags/ni.png": "e608db7e1cecd6afbd1420dd65def4b0",
"assets/packages/country_list_pick/flags/me.png": "5f20ad5680a7bd5979d68363f7c989bb",
"assets/packages/country_list_pick/flags/na.png": "90a4627e0c4b8624d2ca0422d44f0905",
"assets/packages/country_list_pick/flags/ge.png": "a3f4ed852dc2d31c6e00a26c4e43a9ab",
"assets/packages/country_list_pick/flags/sc.png": "86322180a7157d640433b5541ef1cea2",
"assets/packages/country_list_pick/flags/sr.png": "70e657e4b1dc16e0d0671b857d391e40",
"assets/packages/country_list_pick/flags/bt.png": "79013c2037a8dbe805c608a6fca4b334",
"assets/packages/country_list_pick/flags/ly.png": "f19e77eaf524cb9af57108b60cd3b47d",
"assets/packages/country_list_pick/flags/bd.png": "2f4a6ef7a097f677d795ccf42e2a2f11",
"assets/packages/country_list_pick/flags/fk.png": "e17b4125fce77340c33ea23960382280",
"assets/packages/country_list_pick/flags/vc.png": "b2cd5b4716ce8788fa15a4d26ae68e86",
"assets/packages/country_list_pick/flags/mt.png": "ee5f0e8bf7aa9c609c71b0539baf2fcb",
"assets/packages/country_list_pick/flags/mo.png": "3a6d8bece521864cb37d489c37f1633e",
"assets/packages/country_list_pick/flags/ie.png": "7ecceecab6cca823f88cef2cc6f6cece",
"assets/packages/country_list_pick/flags/gn.png": "ee4e661f9d5204573dd544c8843a0bb8",
"assets/packages/country_list_pick/flags/ws.png": "d3a893789296b0caddb296f6de923bf0",
"assets/packages/country_list_pick/flags/gd.png": "ef641ce8a296a00174e6302b80f7b8bb",
"assets/packages/country_list_pick/flags/hr.png": "9a720e9dd52033270f9f1017cfba3bce",
"assets/packages/country_list_pick/flags/tt.png": "90abc818ecfb2f718a8c20fdb9c99de6",
"assets/packages/country_list_pick/flags/ee.png": "1090c5cd1d6edac56ea172b63e298b15",
"assets/packages/country_list_pick/flags/gi.png": "02ec1f60b6633c4aa5b5577a6e1208e7",
"assets/packages/country_list_pick/flags/km.png": "5ac2d15931b9c633bb081adbceaee663",
"assets/packages/country_list_pick/flags/vn.png": "0c15d40ac47d92791edac77ce8a9ef01",
"assets/packages/country_list_pick/flags/pa.png": "368848b034d627f51011bee7ff6f7fe1",
"assets/packages/country_list_pick/flags/az.png": "3422a1d417a2a13abfffaa0ab851c48e",
"assets/packages/country_list_pick/flags/pe.png": "781b81b1ba1d5f9c6409abb4d3c84333",
"assets/packages/country_list_pick/flags/gt.png": "d1a8528dc7ad9490290b2e99a2f2d9af",
"assets/packages/country_list_pick/flags/nf.png": "591a33bd418e460020b80a1727917ab5",
"assets/packages/country_list_pick/flags/tf.png": "75f7175a0a8f2a93d966827f868e78d2",
"assets/packages/country_list_pick/flags/hn.png": "92fe9380f7dbf95783060b134511084b",
"assets/packages/country_list_pick/flags/ms.png": "607f3f0880bbf0a72585919d1c8852cf",
"assets/packages/country_list_pick/flags/mm.png": "b33e771bcb7cb6e8bc67814491b5077d",
"assets/packages/country_list_pick/flags/nl.png": "46b0d4835c3c23c0a8d4ef9f55db2b06",
"assets/packages/country_list_pick/flags/sz.png": "06062677a5d2cbaab9a38e262ff41484",
"assets/packages/country_list_pick/flags/sn.png": "b44808bac0e786e330e2d1ff70fc8661",
"assets/packages/country_list_pick/flags/co.png": "61fa6d5907dedb1dbaa58b7517daad30",
"assets/packages/country_list_pick/flags/bs.png": "4dbfd7a2c196208ce15de6079cacc9cc",
"assets/FontManifest.json": "85b83969d7a710d72374320177da3791",
"index.html": "b10e577864e89ddd8e29eeffa8346a45",
"/": "b10e577864e89ddd8e29eeffa8346a45",
"main.dart.js": "92a1c0844d79ddb4059eb6cad50f2ccb",
"version.json": "e61bda9f0d62d6d13a1a056effab88a4",
"favicon.png": "5dcef449791fa27946b3d35ad8803796"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value + '?revision=' + RESOURCES[value], {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
