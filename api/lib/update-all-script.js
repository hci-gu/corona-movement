const axios = require('axios')

const list = [
  '5ee389a09e15cf0008dc80ce',
  '5ee39a5f5e886e000876182a',
  '5ee39a6c25435e00071454e5',
  '5ee7889a48553d0007a3611b',
  '5ee363476c1e91000780579a',
  '5ee86f904553a80008cc0d89',
  '5ee8bc9ff6c2e20008b701eb',
  '5ee8bf1c798451000803f29c',
  '5ee8bf97f6c2e20008b711e6',
  '5ee8cf75ea82860008dc0db4',
  '5ee8cee6ea82860008dad14b',
  '5ee8d47c04d9710008f3b994',
  '5ee8d65fb6feed0008579b2c',
  '5ee92de6d706dc00079208cc',
  '5f340d17c58aa70008b82954',
  '5f34136fdee3b50007bf00ef',
  '5f34fadc5f85690008d483dd',
  '5f39a4a77f833600087ab3d8',
  '5f3a2929208f8900089c6eee',
  '5f3c125ee859d900089ea590',
  '5f3c12d3e859d900089ea59d',
  '5f3eb15757d13e0008c83118',
  '5f4e18b14413870008718bc4',
  '5f512c1bc2f1f700088f2220',
  '5f55fe18e3365e000891eaf7',
  '5f58a9354f47f80008a08f38',
  '5f58c282446b8f00082e47ea',
  '5f58d435d33e1d0008d24f5c',
  '5f59e0bdd43afa00086db7d7',
  '5f4e1e186b7b030008dd76ba',
  '5f6c4a841c94930008170449',
  '5f6c8fe7f1724600070d4a49',
  '5f49e80055ad82000848a595',
  '5f71cdce11ab5600088ff245',
  '5f72d2fa534fde0007326b21',
  '5f772fc063993d0008607bb4',
  '5f82e6bc50a05d000892f527',
  '5f858daa3975b00008a37eb6',
  '5eea091afd13160007e69a59',
  '5f8451e51a2c660008640d72',
  '5f8456d3a2d98e0008639072',
  '5f887ac66e89f400078303a2',
  '5f8899a47873a40007d4097a',
  '5f8925fed211360008c5b33f',
  '5f892b9b6e872e0008c2bb3c',
  '5f892bc46e872e0008c56ea5',
  '5f89505172a19f000993a2a4',
  '5f89517172a19f0009940099',
  '5f8953f442c60d0008c35575',
  '5f8954c142c60d0008c55177',
  '5f8956b44b77c60008d8cc5e',
  '5f895fa0bf7eb400085a2ddd',
  '5f8960df155f2b000823a5ec',
  '5f8969e31f16920007e134a4',
  '5f8973961aedec0008bea2e0',
  '5f897ac13a107a00077b43c6',
  '5f897d123a107a00077bc1ed',
  '5f897e2f3a107a00077cc35b',
  '5f897f043a107a00077d3163',
  '5f89858b0ab9340008bc9d29',
  '5f898b13ccce2500084dc3a2',
  '5f898cf3ccce2500084e3e57',
  '5f898fbb6487b50008731bf4',
  '5f8991fd839fe900082fd393',
  '5f8991fe839fe900082fd394',
  '5f89950b839fe900082fd683',
  '5f8994b36487b50008732f6e',
  '5f899b0efa9d5c000865b1b9',
  '5f89a44b405c1c0008c25131',
  '5f89a44b405c1c0008c25132',
  '5f89a6b8095e1f0008dfa5c3',
  '5f89b2369966e500084c946b',
  '5f89b60052b1030008100cf3',
  '5f89cd960d85590008f75abf',
  '5f89d89303b9a700088c2e95',
  '5f89ef2c12516700089d09e7',
  '5f89dc9d03b9a700088c437c',
  '5f89e6ca189bea0008bd4ba8',
  '5f89ef6c885b9f0008f4a7c9',
  '5f89f44d885b9f0008f6572c',
  '5f8a0cf08a2b3300078027c4',
  '5f8a29b4dd054f000962434f',
  '5f8aa2bda634f3000798fab9',
  '5f8ab2ba8e417700080c3020',
  '5f8b3b0b8007b00008cc66c6',
  '5f8b4776149bea00086ff23f',
  '5f8b1a2d305c8f0008f9d9cc',
  '5f8b59724718c20008647572',
  '5f8bfd9a9f4d3c0008f39651',
  '5f8ca8d5b0bbe60008dbee3d',
  '5f8d1eb8f909c9000869a836',
  '5f8d3cf551acd90008fb79ef',
  '5f8d4c205e3d2b0008065b22',
  '5f8d5ac94942470008b87253',
  '5f8d6301394c080007e3493a',
  '5f8d91ee0e65f000082e402a',
  '5f8ad96875f4290007d93514',
  '5f8daadfc64fbf0008833c79',
  '5f8dbb0333670e00083da08c',
  '5f8dbd3674142c00087a5574',
  '5f8dbfcf74142c00087a9286',
  '5f8dc17733670e00083e0562',
  '5f8dd6227045f50008327d27',
  '5f8e6a075335330008b58ae6',
  '5f8ea4f02f2cad00082266e6',
  '5f8eca4d9d1ba40008b87c91',
  '5f8ecc968be767000896615f',
]

const update = async (id) => {
  console.log('update', id)
  const response = await axios.get(
    `https://api.mycoronamovement.com/${id}/update`
  )
  console.log('response', response.data)
}

const promiseSeries = (items, method) => {
  const results = []

  function runMethod(item) {
    return new Promise((resolve, reject) => {
      method(item)
        .then((res) => {
          results.push(res)
          resolve(res)
        })
        .catch((err) => reject(err))
    })
  }

  return items
    .reduce(
      (promise, item) => promise.then(() => runMethod(item)),
      Promise.resolve()
    )
    .then(() => results)
}

const run = async () => {
  console.log('start')
  await promiseSeries(list, update)
  console.log('DONE')
}

run()
