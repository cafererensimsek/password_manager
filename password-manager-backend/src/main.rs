use structopt::StructOpt;
use tokio_postgres::{Error, NoTls};

#[tokio::main]
async fn main() -> Result<(), Error> {
    #[derive(Debug, StructOpt)]
    struct Arguments {
        #[structopt(short, long)]
        read: bool,
        #[structopt(short, long)]
        write: bool,
        #[structopt(short, long)]
        change: bool,
        #[structopt(short, long)]
        delete: bool,
        site: String,
        username: Option<String>,
        password: Option<String>,
    }

    let arguments = Arguments::from_args();

    let bool_args: [bool; 4] = [
        arguments.read,
        arguments.write,
        arguments.change,
        arguments.delete,
    ];
    let mut sum: u8 = 0;

    for bool_arg in bool_args {
        if bool_arg {
            sum += 1
        }
    }

    if sum != 1 {
        panic!("You must supply exactly one operation type!")
    }

    let (client, connection) = tokio_postgres::connect(
        "host=localhost user=postgres password=postgres dbname=passwords port=5433",
        NoTls,
    )
    .await?;

    tokio::spawn(async move {
        if let Err(e) = connection.await {
            panic!("connection error: {}", e)
        }
    });

    if arguments.write {
        if arguments.username.is_none() || arguments.password.is_none() || arguments.site.is_empty()
        {
            panic!("You must specify the sitename, username and the password for this operation!")
        }

        client
            .query(
                "insert into passwords (site, password, username) values ($1, $2, $3)",
                &[&arguments.site, &arguments.password, &arguments.username],
            )
            .await?;
    }

    if arguments.delete {
        if arguments.username.is_none() || arguments.site.is_empty() {
            panic!("You must specify the site and the username for this operation!")
        }

        client
            .query(
                "delete from passwords where site = $1 and username = $2",
                &[&arguments.site, &arguments.username],
            )
            .await?;
    }

    if arguments.change {
        if arguments.username.is_none() || arguments.site.is_empty() {
            panic!("You must specify the username for this operation!")
        }

        client
            .query(
                "update passwords set password = $3 where site = $1 and username = $2",
                &[&arguments.site, &arguments.username, &arguments.password],
            )
            .await?;
    }

    if arguments.read {
        if arguments.username.is_none() || arguments.site.is_empty() {
            panic!("You must specify the site and the username for this operation!")
        }

        let row = client
            .query(
                "select password from passwords where site = $1 and username = $2",
                &[&arguments.site, &arguments.username],
            )
            .await?;
        let password: &str = row[0].get(0);

        println!("{}", password);
    }

    Ok(())
}
