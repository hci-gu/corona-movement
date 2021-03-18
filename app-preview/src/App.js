import frame from './frame.svg'

function App() {
  const src = `${process.env.PUBLIC_URL}/app`

  return (
    <div className="App">
      <div className="phone">
        <div className="phone-inner">
          <iframe className="desktop-iframe" title="App preview" src={src}></iframe>
        </div>
        <img alt="Phone frame" src={frame}></img>
      </div>
      <iframe className="mobile-iframe" title="App preview" src={src}></iframe>
    </div>
  );
}

export default App;
