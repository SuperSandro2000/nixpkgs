{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    absinthe = buildMix rec {
      name = "absinthe";
      version = "1.6.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1p5yj1d99p4kg78qw162h2h9ci6z7s2v1ygfs4ggig8rid3ihgm0";
      };

      beamDeps = [ dataloader decimal nimble_parsec telemetry ];
    };

    absinthe_phoenix = buildMix rec {
      name = "absinthe_phoenix";
      version = "2.0.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "139gnamfbba5hyk1fx1zf8vfr0j17fd9q0vxxp9cf39qbj91hsfk";
      };

      beamDeps = [ absinthe absinthe_plug decimal phoenix phoenix_html phoenix_pubsub ];
    };

    absinthe_plug = buildMix rec {
      name = "absinthe_plug";
      version = "1.5.8";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0nkfk5gqbg8yvlysgxfcak7y4lsy8q2jfyqyhql5hwvvciv43c5v";
      };

      beamDeps = [ absinthe plug ];
    };

    argon2_elixir = buildMix rec {
      name = "argon2_elixir";
      version = "2.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "07am18pbfiii8aqg4zim83hrb8g6rznpyxhzmdnzdrzq7hc2xa2f";
      };

      beamDeps = [ comeonin elixir_make ];
    };

    atomex = buildMix rec {
      name = "atomex";
      version = "0.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0yjwl30fhzxha4l73h1m3b7s1q30kp23lzwivzyjrm4kfizp7b7k";
      };

      beamDeps = [ xml_builder ];
    };

    bamboo = buildMix rec {
      name = "bamboo";
      version = "2.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1z74mnizzk5gnjpqplqkjhfxj1pz58gfsa21w15wnh1ggnx18fwc";
      };

      beamDeps = [ hackney jason mime plug ];
    };

    bamboo_phoenix = buildMix rec {
      name = "bamboo_phoenix";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1vkxnfw4xmaz7339nmbcrqlpr260g7c2pfwlg6j897014sxqzf3d";
      };

      beamDeps = [ bamboo phoenix ];
    };

    bamboo_smtp = buildMix rec {
      name = "bamboo_smtp";
      version = "4.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1n8anpp1kws2dsyaa08qicg2662ym8a86hh9yq6x21q5mdb2h6nb";
      };

      beamDeps = [ bamboo gen_smtp ];
    };

    bunt = buildMix rec {
      name = "bunt";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lw3v9kwbbcy1v6ygziiky887gffwwmxvyg4r1v0zm71kzhcgxbs";
      };

      beamDeps = [];
    };

    cachex = buildMix rec {
      name = "cachex";
      version = "3.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rfbbij81zmk6p75z33wg04mfcjqsxzzh67vclllvfjgmfqj609p";
      };

      beamDeps = [ eternal jumper sleeplocks unsafe ];
    };

    certifi = buildRebar3 rec {
      name = "certifi";
      version = "2.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1slp20z2fgcq9p2bbdp1gj218kjqpx5jsa95sq40nq7qqv0yziva";
      };

      beamDeps = [];
    };

    cldr_utils = buildMix rec {
      name = "cldr_utils";
      version = "2.17.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1s2pip4kyap5i2v5b4rwkgrh9h00vixn29c2cdapgwjml6mdsxv0";
      };

      beamDeps = [ certifi decimal ];
    };

    combine = buildMix rec {
      name = "combine";
      version = "0.10.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "06s5y8b0snr1s5ax9v3s7rc6c8xf5vj6878d1mc7cc07j0bvq78v";
      };

      beamDeps = [];
    };

    comeonin = buildMix rec {
      name = "comeonin";
      version = "5.3.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "012zr4s7b5bipng6yszqxkqr1lcv7imf8gyvxad56jachh1396fh";
      };

      beamDeps = [];
    };

    connection = buildMix rec {
      name = "connection";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1746n8ba11amp1xhwzp38yfii2h051za8ndxlwdykyqqljq1wb3j";
      };

      beamDeps = [];
    };

    cors_plug = buildMix rec {
      name = "cors_plug";
      version = "2.0.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1sls8rns2k48qrga0ngysbn9aknapmn3xfn28by1gqbcir0y2jpf";
      };

      beamDeps = [ plug ];
    };

    cowboy = buildErlangMk rec {
      name = "cowboy";
      version = "2.9.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1phv0a1zbgk7imfgcm0dlacm7hbjcdygb0pqmx4s26jf9f9rywic";
      };

      beamDeps = [ cowlib ranch ];
    };

    cowboy_telemetry = buildRebar3 rec {
      name = "cowboy_telemetry";
      version = "0.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1pn90is3k9dq64wbijvzkqb6ldfqvwiqi7ymc8dx6ra5xv0vm63x";
      };

      beamDeps = [ cowboy telemetry ];
    };

    cowlib = buildRebar3 rec {
      name = "cowlib";
      version = "2.11.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ac6pj3x4vdbsa8hvmbzpdfc4k0v1p102jbd39snai8wnah9sgib";
      };

      beamDeps = [];
    };

    credo = buildMix rec {
      name = "credo";
      version = "1.6.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1i9ap0xfylbi5w71cklnvqja1fvm45pygn6jjdz0qwlkb7xhg1k9";
      };

      beamDeps = [ bunt file_system jason ];
    };

    dataloader = buildMix rec {
      name = "dataloader";
      version = "1.0.7";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1apgiifc63d428fnkiww466fw1n2b3834sf9kp88al2air3ndgqj";
      };

      beamDeps = [ ecto ];
    };

    db_connection = buildMix rec {
      name = "db_connection";
      version = "2.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "000zl3y8xw1bhgj47mm4qznyqm24iiflxmlak8d7i6arxhkd4dpa";
      };

      beamDeps = [ connection telemetry ];
    };

    decimal = buildMix rec {
      name = "decimal";
      version = "2.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0xzm8hfhn8q02rmg8cpgs68n5jz61wvqg7bxww9i1a6yanf6wril";
      };

      beamDeps = [];
    };

    dialyxir = buildMix rec {
      name = "dialyxir";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "16hbdhkbqq69v452vx3c0d26mmadkmwr6nvdpr72c5azqi4qxsh7";
      };

      beamDeps = [ erlex ];
    };

    doctor = buildMix rec {
      name = "doctor";
      version = "0.18.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1x485dr8rpdbxlvda8qcp7khs63gzc7ngsj3wik0cb7pcp1qi742";
      };

      beamDeps = [ decimal ];
    };

    earmark_parser = buildMix rec {
      name = "earmark_parser";
      version = "1.4.18";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "15zffivma3fy8sry04y3zkngz53340yff28hh55y1y9wxj2hwjhi";
      };

      beamDeps = [];
    };

    eblurhash = buildRebar3 rec {
      name = "eblurhash";
      version = "1.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0k040pj8hlm8mwy0ra459hk35v9gfsvvgp596nl27q2dj00cl84c";
      };

      beamDeps = [];
    };

    ecto = buildMix rec {
      name = "ecto";
      version = "3.7.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0f463fw0mydnk7vsy7rinsly85lpbn3f3nylzx66b7j7zhwmnvnk";
      };

      beamDeps = [ decimal jason telemetry ];
    };

    ecto_autoslug_field = buildMix rec {
      name = "ecto_autoslug_field";
      version = "3.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "03ycq3c6sm79sx5cxsbv3yc1zvx0ss2a8mig0qr33wc5rz3m5hlf";
      };

      beamDeps = [ ecto slugger ];
    };

    ecto_enum = buildMix rec {
      name = "ecto_enum";
      version = "1.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1r2ffrr020fhfviqn21cv06sd3sp4bf1jra0xrgb3hl1f445rdcg";
      };

      beamDeps = [ ecto ecto_sql postgrex ];
    };

    ecto_shortuuid = buildMix rec {
      name = "ecto_shortuuid";
      version = "0.1.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "152299sdkpmg3wlcyf9lyfp2r515c5lvqnnmjkg6alhjsz7ch5fj";
      };

      beamDeps = [ ecto shortuuid ];
    };

    ecto_sql = buildMix rec {
      name = "ecto_sql";
      version = "3.7.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "108w80dax7h043x079gkycsbmc5k3a4ig1n8lnmn8bz95hpa6hib";
      };

      beamDeps = [ db_connection ecto postgrex telemetry ];
    };

    elixir_feed_parser = buildMix rec {
      name = "elixir_feed_parser";
      version = "2.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "13x2rgckh41zkgbwg63wb7lvyy5xmn7vqq3i7nvy6virggz64g1d";
      };

      beamDeps = [ timex ];
    };

    elixir_make = buildMix rec {
      name = "elixir_make";
      version = "0.6.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05ppvbhqi5m9zk1c4xnrki814sqhxrc7d1dpvfmwm2v7qm8xdjzm";
      };

      beamDeps = [];
    };

    erlex = buildMix rec {
      name = "erlex";
      version = "0.2.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0x8c1j62y748ldvlh46sxzv5514rpzm809vxn594vd7y25by5lif";
      };

      beamDeps = [];
    };

    erlport = buildRebar3 rec {
      name = "erlport";
      version = "0.10.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "06594wi1grqqlbj2xqhh9wzc0wvw03a09gd2r0dis4rans61x4rl";
      };

      beamDeps = [];
    };

    eternal = buildMix rec {
      name = "eternal";
      version = "1.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "10p7m6kv2z2c16gw36wgiwnkykss4lfkmm71llxp09ipkhmy77rc";
      };

      beamDeps = [];
    };

    ex_cldr = buildMix rec {
      name = "ex_cldr";
      version = "2.24.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1fwk7n3rpxsvbz38kaizsmnaacxdnl69slcdj7qlp8hrmixkpqvj";
      };

      beamDeps = [ certifi cldr_utils decimal gettext jason nimble_parsec plug ];
    };

    ex_cldr_calendars = buildMix rec {
      name = "ex_cldr_calendars";
      version = "1.17.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1d3vvhdb319a7sirgnp44978lyrby7qfxfmqsh728bq4x1vf8mqd";
      };

      beamDeps = [ ex_cldr ex_doc jason ];
    };

    ex_cldr_currencies = buildMix rec {
      name = "ex_cldr_currencies";
      version = "2.12.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "04lgmgqxlgaczha0yr32m691zhwc9s9ghcgyzgxszpww8pxyhpi4";
      };

      beamDeps = [ ex_cldr jason ];
    };

    ex_cldr_dates_times = buildMix rec {
      name = "ex_cldr_dates_times";
      version = "2.10.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1wnfhac4b719iyrcxn97az63fia3aw5rmlmd6m2c3h5cypvq9409";
      };

      beamDeps = [ ex_cldr_calendars ex_cldr_numbers jason ];
    };

    ex_cldr_languages = buildMix rec {
      name = "ex_cldr_languages";
      version = "0.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0zhr2k4lwfn4l4rwfin541dqa7s3qckq3spq15ynnz5kj56kwivb";
      };

      beamDeps = [ ex_cldr jason ];
    };

    ex_cldr_numbers = buildMix rec {
      name = "ex_cldr_numbers";
      version = "2.23.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19m4xzsv6sn6ks62pa6kk1myd6rmhm7brjrgn800kmbh3hwy8m9c";
      };

      beamDeps = [ decimal ex_cldr ex_cldr_currencies jason ];
    };

    ex_doc = buildMix rec {
      name = "ex_doc";
      version = "0.26.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "13f7h694aja93k9lfnn6c568d5yrzxw791mpblsli6ja95pdcx97";
      };

      beamDeps = [ earmark_parser makeup_elixir makeup_erlang ];
    };

    ex_ical = buildMix rec {
      name = "ex_ical";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1yxyflmkvmglks7whmbz944kyq6qljjpki666dk9w9g058xlfxnv";
      };

      beamDeps = [ timex ];
    };

    ex_machina = buildMix rec {
      name = "ex_machina";
      version = "2.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1y2v4j1zg1ji8q8di0fxpc3z3n2jmbnc85d6hx68j4fykfisg6j1";
      };

      beamDeps = [ ecto ecto_sql ];
    };

    ex_optimizer = buildMix rec {
      name = "ex_optimizer";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "11i2npj15w3a91lxdpf9ll7lpdv99zf7y9bg5yz6d2ympicw1xg6";
      };

      beamDeps = [ file_info ];
    };

    ex_unit_notifier = buildMix rec {
      name = "ex_unit_notifier";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0cp3msbal2pc4w1bydibqs91r7qdl60xgi5fy3bqmrhdsp4l907k";
      };

      beamDeps = [];
    };

    excoveralls = buildMix rec {
      name = "excoveralls";
      version = "0.14.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1h9ig4hijdhp73isl830hip7s7g78ykz19i8jx8pl72cvzr05az3";
      };

      beamDeps = [ hackney jason ];
    };

    exgravatar = buildMix rec {
      name = "exgravatar";
      version = "2.0.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1q80jcrnagivsjr9mz0z9h4bwlf0xyyx6ijl7szd74c9ppwqz8dc";
      };

      beamDeps = [];
    };

    export = buildMix rec {
      name = "export";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "07q2l7f9yr3bd3xqc5q1qa9qrhnjzc9xnjrg6lj1hgq5yi7l99rx";
      };

      beamDeps = [ erlport ];
    };

    fast_html = buildMix rec {
      name = "fast_html";
      version = "2.0.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "01k51qri44535b1hwixlxk7151vph6vapswlfq918g245544ypv0";
      };

      beamDeps = [ elixir_make nimble_pool ];
    };

    fast_sanitize = buildMix rec {
      name = "fast_sanitize";
      version = "0.2.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1qjnbs63q0d95dqhh2r9sz3zpg2y4hjy23kxsqanwf6h21njibg8";
      };

      beamDeps = [ fast_html plug ];
    };

    file_info = buildMix rec {
      name = "file_info";
      version = "0.0.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19c14xv0xzbl3m6y5p7dlxn8sfqi9bff8pv722837ff8q80svrsh";
      };

      beamDeps = [ mimetype_parser ];
    };

    file_system = buildMix rec {
      name = "file_system";
      version = "0.2.10";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1p0myxmnjjds8bbg69dd6fvhk8q3n7lb78zd4qvmjajnzgdmw6a1";
      };

      beamDeps = [];
    };

    floki = buildMix rec {
      name = "floki";
      version = "0.32.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ggcxk3kkpmmd2sar2scj09lha1c6ziba9j8db1332gxw7592nhw";
      };

      beamDeps = [ html_entities ];
    };

    gen_smtp = buildRebar3 rec {
      name = "gen_smtp";
      version = "1.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1dwszws49n7sza38js2999yzl3mn1yirxhyb9114mzby07651g2i";
      };

      beamDeps = [ hut ranch ];
    };

    geo = buildMix rec {
      name = "geo";
      version = "3.4.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ljmnbz3a0kh0hri64df87c8zic9xk6bxqffcfqchzj3wn92hgz2";
      };

      beamDeps = [ jason ];
    };

    geo_postgis = buildMix rec {
      name = "geo_postgis";
      version = "3.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0wqa0ilb4bgyvy8pimsm1jaj43319d2amp4zs15lsadj1h9206j5";
      };

      beamDeps = [ geo jason postgrex ];
    };

    geohax = buildMix rec {
      name = "geohax";
      version = "0.4.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1zh5vz6j75d6s5g4867hqhg38px4i7cl282f05k0qhg8j1rg040d";
      };

      beamDeps = [];
    };

    geolix = buildMix rec {
      name = "geolix";
      version = "2.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1pq1qcjaqsnnvsbgzzbfdj290n9mkp808cj45kppvfyhircbyhl7";
      };

      beamDeps = [];
    };

    geolix_adapter_mmdb2 = buildMix rec {
      name = "geolix_adapter_mmdb2";
      version = "0.6.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "16r6q2qmgdpj5pvb36s3rgfd1qm6rnzp8szqzp7i18z8x8prdzq6";
      };

      beamDeps = [ geolix mmdb2_decoder ];
    };

    gettext = buildMix rec {
      name = "gettext";
      version = "0.19.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0pmdg5rwlwvzrk61vr0wwmx57i0ddcyxmzjxcnv9pnpba97jfyiz";
      };

      beamDeps = [];
    };

    guardian = buildMix rec {
      name = "guardian";
      version = "2.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lphqmhxlg1289gkpqipf9hrzjnb0dq62jgy7z9lnlhqiz8c9d89";
      };

      beamDeps = [ jose plug ];
    };

    guardian_db = buildMix rec {
      name = "guardian_db";
      version = "2.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0w0d9bwsiz7hw9i7b3v8gpjsvblzhbkcnnpxlzrrbhwjmi1xbrzq";
      };

      beamDeps = [ ecto ecto_sql guardian postgrex ];
    };

    guardian_phoenix = buildMix rec {
      name = "guardian_phoenix";
      version = "2.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1350z7sk4m8n2wxllnjm07gzpm8ybm3811i23wijn68mcwj3kx11";
      };

      beamDeps = [ guardian phoenix ];
    };

    hackney = buildRebar3 rec {
      name = "hackney";
      version = "1.18.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0pjwbf87nqj2ki3i076whrswh2cdhklj6cbaikdj1mq40xidmz4s";
      };

      beamDeps = [ certifi idna metrics mimerl parse_trans ssl_verify_fun unicode_util_compat ];
    };

    html_entities = buildMix rec {
      name = "html_entities";
      version = "0.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1k7xyj0q38ms3n5hbn782pa6w1vgd6biwlxr4db6319l828a6fy5";
      };

      beamDeps = [];
    };

    http_signatures = buildMix rec {
      name = "http_signatures";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "18s2b5383xl2qjijkxag4mvwk2p5kv2fw58c9ii7pk12fc08lfyc";
      };

      beamDeps = [];
    };

    httpoison = buildMix rec {
      name = "httpoison";
      version = "1.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0fiwkdrbj7mmz449skp7laz2jdwsqn3svddncmicd46gk2m9w218";
      };

      beamDeps = [ hackney ];
    };

    hut = buildRebar3 rec {
      name = "hut";
      version = "1.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0qxmkazkakrmvd9n1im4ad43wxgh189fqcd9lfsz58fqan2x45by";
      };

      beamDeps = [];
    };

    idna = buildRebar3 rec {
      name = "idna";
      version = "6.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1sjcjibl34sprpf1dgdmzfww24xlyy34lpj7mhcys4j4i6vnwdwj";
      };

      beamDeps = [ unicode_util_compat ];
    };

    inet_cidr = buildMix rec {
      name = "inet_cidr";
      version = "1.0.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1g61i08cizr99ivy050lv8fmvnwia9zmipfvlwff8jkhi40x78k4";
      };

      beamDeps = [];
    };

    ip_reserved = buildMix rec {
      name = "ip_reserved";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1zm4820yvdashvz14p9jhv2bwc1hshvyym1zx84yzjhiwavd5z2m";
      };

      beamDeps = [ inet_cidr ];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1b620901micds3q2pfnwcp861hjiwx0wpyahgvnf142k4m8izz2k";
      };

      beamDeps = [ decimal ];
    };

    jose = buildMix rec {
      name = "jose";
      version = "1.11.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1lj715gzl022yc47qsg9712x8nc9wi7x70msv8c3lpym92y3y54q";
      };

      beamDeps = [];
    };

    jumper = buildMix rec {
      name = "jumper";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0cvlbfkapkvbwaijmjq3cxg5m6yv4rh69wvss9kfj862i83mk31i";
      };

      beamDeps = [];
    };

    junit_formatter = buildMix rec {
      name = "junit_formatter";
      version = "3.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0rm6hzlm5wdd497ywywi7gjypkd0hkl42zacmrav292kj880812d";
      };

      beamDeps = [];
    };

    linkify = buildMix rec {
      name = "linkify";
      version = "0.5.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0i7r9z49sdxs7nrnh2igmwzzmq9ih4fm02a046klmnps49z8q4m3";
      };

      beamDeps = [];
    };

    makeup = buildMix rec {
      name = "makeup";
      version = "1.0.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1a9cp9zp85yfybhdxapi9haa1yykzq91bw8abmk0qp1z5p05i8fg";
      };

      beamDeps = [ nimble_parsec ];
    };

    makeup_elixir = buildMix rec {
      name = "makeup_elixir";
      version = "0.15.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0x9yhal7zngssyrgrm2gxq1d91phr51jpvackpsfyclvs14aw8zx";
      };

      beamDeps = [ makeup nimble_parsec ];
    };

    makeup_erlang = buildMix rec {
      name = "makeup_erlang";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1fvw0zr7vqd94vlj62xbqh0yrih1f7wwnmlj62rz0klax44hhk8p";
      };

      beamDeps = [ makeup ];
    };

    meck = buildRebar3 rec {
      name = "meck";
      version = "0.9.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "09jq0jrsd3dwzjlnwqjv6m9r2rijgiv57yja6jl41p2p2db4yd41";
      };

      beamDeps = [];
    };

    metrics = buildRebar3 rec {
      name = "metrics";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05lz15piphyhvvm3d1ldjyw0zsrvz50d2m5f2q3s8x2gvkfrmc39";
      };

      beamDeps = [];
    };

    mime = buildMix rec {
      name = "mime";
      version = "1.6.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19qrpnmaf3w8bblvkv6z5g82hzd10rhc7bqxvqyi88c37xhsi89i";
      };

      beamDeps = [];
    };

    mimerl = buildRebar3 rec {
      name = "mimerl";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08wkw73dy449n68ssrkz57gikfzqk3vfnf264s31jn5aa1b5hy7j";
      };

      beamDeps = [];
    };

    mimetype_parser = buildMix rec {
      name = "mimetype_parser";
      version = "0.1.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lm8yzcmg17nhvr4p4dbmamb280a9dzqx4rwv66ffz40cz2q13vx";
      };

      beamDeps = [];
    };

    mix_test_watch = buildMix rec {
      name = "mix_test_watch";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1hrfh7hg3iwmvzwwyshdddgjxwc2ci898lyak7c0zdybfv2b3djj";
      };

      beamDeps = [ file_system ];
    };

    mmdb2_decoder = buildMix rec {
      name = "mmdb2_decoder";
      version = "3.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "13pa1gr8c7pdw8i9vr32rrvcl790f9ndkxmrrqfqslqm54jck79m";
      };

      beamDeps = [];
    };

    mock = buildMix rec {
      name = "mock";
      version = "0.3.7";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0p3yrx049fdw88kjidngd2lkwqkkyck5r51ng2dxj7z41539m92d";
      };

      beamDeps = [ meck ];
    };

    mogrify = buildMix rec {
      name = "mogrify";
      version = "0.9.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "01bzbfd0c932acnla5s3b5f9gvyyiwi0rgs815f15lipjccdykhk";
      };

      beamDeps = [];
    };

    mox = buildMix rec {
      name = "mox";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0s9l2ddjkrk7pnrnmsvn8g3hd6x5cw03dr3zxys8vlcrakm0vg1m";
      };

      beamDeps = [];
    };

    nimble_csv = buildMix rec {
      name = "nimble_csv";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0amij6y3pgkpazhjr3madrn9c9lv6malq11ln1w82562zhbq2qnh";
      };

      beamDeps = [];
    };

    nimble_parsec = buildMix rec {
      name = "nimble_parsec";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1h82s3mn9zg4cm58x3brk77j81x4cm0lw88gn14sr98mfld8gcjj";
      };

      beamDeps = [];
    };

    nimble_pool = buildMix rec {
      name = "nimble_pool";
      version = "0.2.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ipaxd8ik23xl1kzfd955316s9vvnp6956ba9rv8gdrpw5qq0zin";
      };

      beamDeps = [];
    };

    oauth2 = buildMix rec {
      name = "oauth2";
      version = "2.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rz7j456fi5qmakilfi36zd82w1zpsf3fjbrvkyzk1bkmij866w8";
      };

      beamDeps = [ hackney ];
    };

    oauther = buildMix rec {
      name = "oauther";
      version = "1.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0kn0msy3z0rx7l4pp8zc5r7yhvmwa3sscr08gfi2rivmm278isvq";
      };

      beamDeps = [];
    };

    oban = buildMix rec {
      name = "oban";
      version = "2.10.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1hq7wc98kha2wb0rkxqj2jchk4v8v71xdcgx7rmcsis1340xs70n";
      };

      beamDeps = [ ecto_sql jason postgrex telemetry ];
    };

    paasaa = buildMix rec {
      name = "paasaa";
      version = "0.5.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "15kmzk44npk7vj1w6vwspab5qrgj659yw67wjdm3k171p0ril7sp";
      };

      beamDeps = [];
    };

    parse_trans = buildRebar3 rec {
      name = "parse_trans";
      version = "3.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12w8ai6b5s6b4hnvkav7hwxd846zdd74r32f84nkcmjzi1vrbk87";
      };

      beamDeps = [];
    };

    phoenix = buildMix rec {
      name = "phoenix";
      version = "1.6.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "03783r152mhkv392gknd7iigqf843lglfdh61ql9k134r9931p4p";
      };

      beamDeps = [ jason phoenix_pubsub phoenix_view plug plug_cowboy plug_crypto telemetry ];
    };

    phoenix_ecto = buildMix rec {
      name = "phoenix_ecto";
      version = "4.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1h9wnjmxns8y8dsr0r41ks66gscaqm7ivk4gsh5y07nkiralx1h9";
      };

      beamDeps = [ ecto phoenix_html plug ];
    };

    phoenix_html = buildMix rec {
      name = "phoenix_html";
      version = "3.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ky5idgid1psz6hmh2b2kmj6n974axww74hrxwv02p6jasx9gv1n";
      };

      beamDeps = [ plug ];
    };

    phoenix_live_reload = buildMix rec {
      name = "phoenix_live_reload";
      version = "1.3.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1b5blinpmzdgspgk0dsy01bfjwwnhikb1gfiwnx8smazdrkrcrvn";
      };

      beamDeps = [ file_system phoenix ];
    };

    phoenix_live_view = buildMix rec {
      name = "phoenix_live_view";
      version = "0.17.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1qxhb1lw68vkz6h7q6ki0502pklfxgsx8sf72j11pxsd7mm6wn65";
      };

      beamDeps = [ jason phoenix phoenix_html telemetry ];
    };

    phoenix_pubsub = buildMix rec {
      name = "phoenix_pubsub";
      version = "2.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0wgpa19l6xar0k2m117iz2kq3cw433llp07sqswpf5969y698bf5";
      };

      beamDeps = [];
    };

    phoenix_view = buildMix rec {
      name = "phoenix_view";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "036v4lq2b55df17w1bxpv901diw228c5hbkf4hh34qzm2qjkxgl2";
      };

      beamDeps = [ phoenix_html ];
    };

    plug = buildMix rec {
      name = "plug";
      version = "1.12.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "02ykw1666amp8mjzfwgm155fp4fszg2nv5l4nya09hkvfyd7jznm";
      };

      beamDeps = [ mime plug_crypto telemetry ];
    };

    plug_cowboy = buildMix rec {
      name = "plug_cowboy";
      version = "2.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0i0hxbpkbgv2zi4z04x0l207dgbks2kj4h6kr1h8sq68fkvqfvpa";
      };

      beamDeps = [ cowboy cowboy_telemetry plug ];
    };

    plug_crypto = buildMix rec {
      name = "plug_crypto";
      version = "1.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1nxnxj62iv4yvm4771jbxpj3l4brn2crz053y12s998lv5x1qqw7";
      };

      beamDeps = [];
    };

    postgrex = buildMix rec {
      name = "postgrex";
      version = "0.15.13";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1wbhmz93q74xbxcgnhcp3j3jhzxnzwkjlqwmd9fgxzkwm7hpdyrz";
      };

      beamDeps = [ connection db_connection decimal jason ];
    };

    progress_bar = buildMix rec {
      name = "progress_bar";
      version = "2.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "11wgy5qxr7yn3f299v2rlab6vjyqas13fag7jjha6jgil9cfn695";
      };

      beamDeps = [ decimal ];
    };

    ranch = buildRebar3 rec {
      name = "ranch";
      version = "1.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rfz5ld54pkd2w25jadyznia2vb7aw9bclck21fizargd39wzys9";
      };

      beamDeps = [];
    };

    remote_ip = buildMix rec {
      name = "remote_ip";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "01zrrb4fakhf8wsvsivis0z3y8mbssg65adn9civahqcwpacm7wy";
      };

      beamDeps = [ combine plug ];
    };

    sentry = buildMix rec {
      name = "sentry";
      version = "8.0.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "10qqkqvykw8v3xdw9j19jgg3kwjfdrp9sz3wg0vk2bqnf822s6h5";
      };

      beamDeps = [ hackney jason plug plug_cowboy ];
    };

    shortuuid = buildMix rec {
      name = "shortuuid";
      version = "2.1.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lyk7bv89v3wfymg9jhml12rygi15s3wwpi7nscm3sh0fprw9c6r";
      };

      beamDeps = [];
    };

    sitemapper = buildMix rec {
      name = "sitemapper";
      version = "0.6.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rc3d3d1n3qkg8cf2xv2spwfy9m8mm8bj6sfmxcfycjr4spsi4kk";
      };

      beamDeps = [ xml_builder ];
    };

    sleeplocks = buildRebar3 rec {
      name = "sleeplocks";
      version = "1.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1q823i5bisc83pyssgrqkggyxiasm7b8dygzj2r943adzyp3gvl4";
      };

      beamDeps = [];
    };

    slugger = buildMix rec {
      name = "slugger";
      version = "0.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1fmgnl4ydq4ivbfk1a934vcn0d0wb24lhnvcmqg5sq0jwz8dxl10";
      };

      beamDeps = [];
    };

    sobelow = buildMix rec {
      name = "sobelow";
      version = "0.11.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0g558rki9198a2plgdadsbjxaalyh6nhma84jf0g95pzgqx3d5wq";
      };

      beamDeps = [ jason ];
    };

    ssl_verify_fun = buildRebar3 rec {
      name = "ssl_verify_fun";
      version = "1.1.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1026l1z1jh25z8bfrhaw0ryk5gprhrpnirq877zqhg253x3x5c5x";
      };

      beamDeps = [];
    };

    struct_access = buildMix rec {
      name = "struct_access";
      version = "1.1.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0sjq5v0zdqx7iqs0hqa7lfqzxf4jzi8rb409aywq2q12q3f13i74";
      };

      beamDeps = [];
    };

    sweet_xml = buildMix rec {
      name = "sweet_xml";
      version = "0.7.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1s56f3ak35z2h9gk3g302akhwx7p4lrylichv4s4ai8g2a5fd538";
      };

      beamDeps = [];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0yn5mr83hrx0dslsqxmfr5zf0a65hdak6926zd72i85lb7x0kg3k";
      };

      beamDeps = [];
    };

    tesla = buildMix rec {
      name = "tesla";
      version = "1.4.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0mv48vgby1fv9b2npc0ird3y4isr10np3a3yas3v5hfyz54kll6m";
      };

      beamDeps = [ hackney jason mime telemetry ];
    };

    timex = buildMix rec {
      name = "timex";
      version = "3.7.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12f5w9i3msv5nc51zcwyrh875vb2wrb8qscnp2awf7nbg5zk55m2";
      };

      beamDeps = [ combine gettext tzdata ];
    };

    tz_world = buildMix rec {
      name = "tz_world";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1y3qyjzwmrzxyg3iad5rh1hv231qzp0z66radm46sfwig2hflylx";
      };

      beamDeps = [ certifi geo jason ];
    };

    tzdata = buildMix rec {
      name = "tzdata";
      version = "1.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "11wpm1mjla8hbkb5mssprg3gsq1v24s8m8nyk3hx5z7aaa1yr756";
      };

      beamDeps = [ hackney ];
    };

    ueberauth = buildMix rec {
      name = "ueberauth";
      version = "0.6.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0q0vz7vlbw66a32d7yij3p5l4a59bi0sygiynn8na38ll7c97hmg";
      };

      beamDeps = [ plug ];
    };

    ueberauth_discord = buildMix rec {
      name = "ueberauth_discord";
      version = "0.6.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1g7sw9xaqpz4ps18wsvrl2lnb9ggax6swz4lfjlw7mn1j40rdsn5";
      };

      beamDeps = [ oauth2 ueberauth ];
    };

    ueberauth_facebook = buildMix rec {
      name = "ueberauth_facebook";
      version = "0.8.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "01p8av7yv8vm39j4855c2bh1l20y7b5vnh2p8fypqi86cykzpzaw";
      };

      beamDeps = [ oauth2 ueberauth ];
    };

    ueberauth_github = buildMix rec {
      name = "ueberauth_github";
      version = "0.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "18q76fjf4cff1hs7ly5f2d31z2b87lrz6lll0sx1j1vv380cqp5n";
      };

      beamDeps = [ oauth2 ueberauth ];
    };

    ueberauth_google = buildMix rec {
      name = "ueberauth_google";
      version = "0.10.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0l16k69nnlflb585yr7drrs0lm9q38yrskx4ra5rp8i4zmsjb3hl";
      };

      beamDeps = [ oauth2 ueberauth ];
    };

    ueberauth_twitter = buildMix rec {
      name = "ueberauth_twitter";
      version = "0.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0s24zl2h5dh44yq4qarzp955ds4phpna1xb11j606qx2gh2cjagv";
      };

      beamDeps = [ httpoison oauther ueberauth ];
    };

    unicode_util_compat = buildRebar3 rec {
      name = "unicode_util_compat";
      version = "0.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08952lw8cjdw8w171lv8wqbrxc4rcmb3jhkrdb7n06gngpbfdvi5";
      };

      beamDeps = [];
    };

    unsafe = buildMix rec {
      name = "unsafe";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rahpgz1lsd66r7ycns1ryz2qymamz1anrlps986900lsai2jxvc";
      };

      beamDeps = [];
    };

    web_push_encryption = buildMix rec {
      name = "web_push_encryption";
      version = "0.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "18p2f1gqkg209vf3nychjxy7xpxhgiwyhn4halvr7yr2fvjv50jg";
      };

      beamDeps = [ httpoison jose ];
    };

    xml_builder = buildMix rec {
      name = "xml_builder";
      version = "2.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1jb29bv6hgz7z2bdw119am6z17nkg1033936h4smsmhpp4pxarlx";
      };

      beamDeps = [];
    };
  };
in self

